package MasterWebInterface::Handler::ServInfo;
use strict;
use warnings;
use utf8;
use TUWF ':html';
use POSIX 'strftime';
use Exporter 'import';

TUWF::register(
    qr{(.[\w]{1,20})/([\:\.\w]{9,35})} => \&show_server,
);

################################################################################
# Display server information
# Verify if game and server (ip:hostport) exist. Display as many available
# values as possible.
# Display error pages if not found or incorrect.
################################################################################
sub show_server 
{
    my ($self, $gamename, $s_addr) = @_;
    
    # parse from ipv4/6 and soft sanity check
    my ($ip, $port) = $self->from_addr_str($s_addr);
    
    # select server from database
    my $info = $self->dbGetServerInfo(
        ip => $ip,
        hostport => $port,
        limit => 1,
    )->[0];
    
    # either redirect or show error when no info was found
    if (!defined $info)
    {
        # try if query port was provided instead
        my $attempt = $self->dbGetServerInfo(
            ip => $ip, 
            port => $port, 
            limit => 1
        )->[0];
        
        # if it exists now, automatically redirect to this page (don't show info here)
        if (defined $attempt && defined $attempt->{gamename} && defined $attempt->{hostport} ) 
        {
            $self->resRedirect("/$attempt->{gamename}/$ip:$attempt->{hostport}");
            return;
        }
        
        # otherwise not found in database, soft error page (no 404 status)
        $self->htmlHeader(title => 'Server not found');
        $self->htmlSearchBox(title => "Servers", action => "/s", sel => 's', fq => '');
        
        div class => "mainbox warning";
            div class => "header";
                h1 'Server not found';
                p "The requested information is not in our database.";
            end;
            
            div class => "description";
                p;
                    txt 'It seems the server you were looking for does not exist in our database,';
                    br;
                    txt 'perhaps our search function may yield results?';
                end;
                
                p;
                    txt "You tried to access ";
                    span class => "hilit", $self->to_ipv4_str($s_addr) // "[no ip]";
                    txt " in ";
                    span class => "hilit", $gamename;
                    txt ".";
                end;
            end;
        end;
        $self->htmlFooter;

        return;
    }
    
    
    #
    # info exists. sanity checks
    $gamename = $info->{gamename} // $gamename;
    my $gamedescription = $self->dbGetGameDesc($info->{gamename}) // $info->{gamename};
    
    #
    # generate info page
    $self->htmlHeader(title => $info->{hostname} // "Server");
    $self->htmlSearchBox(
        title => "$gamedescription Servers", 
        action => "/s/$gamename", 
        sel => 's', 
        fq => ''
    );
    
    # serverinfo box
    div class => "mainbox detail";
    
        div class => "header";
            h1 title  => $info->{hostname} // "[unnamed $gamename server]",
                         $info->{hostname} // "[unnamed $gamename server]"; 
        end;
        
        #
        # Map thumbnail and bot info
        #
        div class => "container";

            # find the correct thumbnail, otherwise game default, otherwise 333 default
            div class => "thumbnail";
                my $mapfig = "/map/default/333networks.jpg";
                my $mapfile = lc ($info->{mapname} // "");
                
                # if map figure exists, use it
                if (-e "$self->{root}/s/map/$gamename/$mapfile.jpg") 
                {
                    # map image
                    $mapfig = "/map/$gamename/$mapfile.jpg";
                }
                # if not, game default image
                elsif (-e "$self->{root}/s/map/default/$gamename.jpg") 
                {
                    # game image
                    $mapfig = "/map/default/$gamename.jpg";
                }
                # otherwise 333networks default
                else
                {
                    # 333networks default
                    $mapfig = "/map/default/333networks.jpg";
                }
                
                # map title/name (not lowercase)
                my $mapname  = $info->{mapname} // $info->{maptitle} // "Untitled";
                my $maptitle = ( $info->{maptitle} && lc $info->{maptitle} ne "untitled" ) 
                             ? $info->{maptitle}
                             : $mapname;
                             
                img src => $mapfig, 
                    alt => $mapfig, 
                    title => $mapname;
                span $maptitle;
            end;
            
            table class => "mapinfo";
                # numplayer field
                Tr;
                    td class => "wc1", "Players:";
                    td;
                        txt $info->{numplayers} // 0;
                        txt "/";
                        txt $info->{maxplayers} // 0;
                    end;
                end;
                
                
                Tr;
                    td "Bots:";
                    td;
                    if ($info->{botskill} or $info->{minplayers}) 
                    {
                        txt $info->{minplayers} // 0;
                        txt " ";
                        txt $info->{botskill} // "";
                        txt " bot"; 
                        txt ($info->{minplayers} && $info->{minplayers} == 1 ? "" : "s");
                    }
                    else
                    {
                        txt "No";
                    }
                    end;
                end;
            end; #table
        end; # container
        
        #
        # specific server entry information
        table class => "serverinfo";
            Tr; 
                th class => "wc1", title => "Server ID: " . ($info->{id} // "-1"), "Server Info"; 
                th ""; 
            end;
            
            # server address
            Tr; 
                td "Address:"; 
                td title => $info->{queryport} // 0;
                    txt $self->to_ipv4_str($info->{ip}) // "0.0.0.0";
                    txt ":";
                    txt $info->{hostport} // 0;
                end;
            end;
            
            # contact
            if ($info->{adminname}) 
            {
                Tr;
                    td "Admin:"; 
                    td $info->{adminname};
                end;
            }
            
            # always display contact
            Tr;
                td class => "wc1", "Contact:";
                td;
                    if ($info->{adminemail}) 
                    {
                        txt $info->{adminemail}
                    }
                    else 
                    {
                        i; 
                            txt "This server has no contact information listed "; 
                            a href => "https://ut99.org/viewtopic.php?f=33&t=6660", "[?]"; 
                        end;
                    }
                end;
            end;
            
            # location data
            Tr;
                td class => "wc1", "Location:";
                
                my ($flag, $country) = $self->countryflag($info->{country} // "");
                td;
                    img class => "flag", src => "/flag/$flag.svg";
                    txt " ". $country;
                end;
            end;
            
            # added / updated
            Tr; 
            {
                td "Added:";
                my @t = gmtime( time - ( $info->{dt_added} // 0 ) );
                my $sig = 0;
                my $diff = "";
                if ($t[5]-70)
                {
                    $diff .= $t[5]-70 
                          .  " year"
                          . ( ($t[5]-70==1) ? "" : "s" ); 
                    $sig++;
                }
                if ($t[7])
                {
                    $diff .= ($sig?", ":"")
                          . $t[7]
                          . " day"
                          . ( ($t[7]==1) ? "" : "s") 
                }
                
                if ($diff eq "") 
                {
                    $diff = "Less than one day";
                }
                td $diff . " ago (" . (strftime "%e %b %Y", gmtime ($info->{dt_added} // 0) ) .")";
            }
            end;
            
            Tr;
            {
                td "Last seen:";
                td;
                    my @t = gmtime( time - ( $info->{dt_updated} // 0 ) );
                    if ($t[5]-70 // $t[7]) 
                    {
                        # more than 1 day? show date
                        span class => "r", (strftime "%e %b %Y", gmtime ($info->{dt_updated} // 0) );
                    }
                    else 
                    {
                        # less than 1 day? show "time ago"
                        my $diff = "";
                        $diff .= ($t[2] ? $t[2]." hour"  . ( $t[2]>1 ? "s, " : ", ") : "");
                        $diff .= ($t[1] ? $t[1]." minute". ( $t[1]>1 ? "s, " : ", ") : "");
                        $diff .= ($t[0] ? $t[0]." second". ( $t[0]>1 ? "s"   : " " ) : "0 seconds");
                        $diff .= " ago";
                        span $diff;
                    }
                end;
            }
            end;
            
            
            # TODO: move flags to header
            Tr;
                td "Flags: ";
                td;
                    # uplink/sync
                    span title => "direct uplink or manually added?", 
                        ($info->{f_direct} ? "💻 uplink" : "🤚 manual"); 
                        
                    txt ", ";
                    
                    span title => "authenticated game server?",
                        ($info->{f_auth} ? "✅ authed" : "❌ insecure");
                    txt ", ";
                    
                    span title => "server blacklisted for violating 333networks policy?",
                        ($info->{f_blacklist} ? "blacklisted" : "compliant");
                    
                    txt ", ";
                    span title => "does the server require a password to join?",
                        ($info->{passworded} ? 
                            ($info->{passworded} =~ /(true|1)/i ? "🔒 password" : "🔓 open")
                            : "🔓 open");
                end;
            end;
        end; # table serverinfo
        
        #
        # Specific game and version information
        table class => "gameinfo";
            Tr; 
                th class => "wc1", "Game Info"; 
                th ""; 
            end;
            
            Tr;
                td "Game:"; 
                td;
                    a href => "/s/$gamename", $gamedescription;
                end;
            end;
            if ($info->{gametype}) 
            {
                Tr;
                    td "Type:"; 
                    td $info->{gametype};
                end;
            }
            if ($info->{gamestyle}) 
            {
                Tr;
                    td "Style:"; 
                    td $info->{gamestyle};
                end;
            }
            if ($info->{gamever}) 
            {
                Tr;
                    td "Version:"; 
                    td $info->{gamever};
                end;
            }
        end; #gameinfo
        
        #
        # Mutator list
        table class => "mutators";
            Tr;
                th "Mutators";
            end;
            Tr;
                td;
                    if (defined $info->{mutators} && $info->{mutators} ne "None") 
                    {   
                        txt $info->{mutators};
                    }
                    else 
                    {
                        i "This server does not have any mutators listed.";
                    }
                end;
            end;
        end; #mutators
        
        #
        # Player info
        table class => "players";
            my $player = $self->dbGetPlayerInfoList(sid => $info->{id});
            my %team = (0 => "#e66",
                        1 => "#66e",
                        2 => "#6e6",
                        3 => "#ee6",
                        4 => "#fe6",
                      255 => "#aaa");
        
            # iterate players and colors
            Tr; 
                th class => "wc1",   'Player Info'; 
                th class => "frags", 'Frags'; 
                th class => "mesh",  'Mesh'; 
                th class => "skin",  'Skin'; 
                th class => "ping",  'Ping'; 
            end;
            
            for (my $i = 0; defined $player->[$i]->{name}; $i++) 
            {
                # determine teamcolor
                my $teamcolor = ( defined $player->[$i]->{team} && 
                                          $player->[$i]->{team} =~ m/^([0-4]|255)$/i) 
                        ? $team{$player->[$i]->{team}} 
                        : "#aaa";
                
                Tr $i % 2 ? (class => 'odd') : (), style => 'color:'.$teamcolor;
                    td class => "wc1", title => $player->[$i]->{team} // "None";
                        txt $player->[$i]->{name} // "[no name]";
                        if ($player->[$i]->{ngsecret} && $player->[$i]->{ngsecret} =~ m/^bot$/i)
                        {
                            txt " (bot)";
                        }
                    end;
                    td class => "frags", $player->[$i]->{frags} // 0;
                    td class => "mesh",  $player->[$i]->{mesh}  // "";
                    td class => "skin",  $player->[$i]->{skin}  // "";
                    td class => "ping",  $player->[$i]->{ping}  // 0;
                end;
            }
            if ( ! defined $player->[0]->{name}) 
            {
                Tr; 
                    td colspan => 5; 
                        i "There is no player information available."; 
                    end; 
                end;
            }
        end; # playerinfo
    
        #
        # Team info
        table class => "teaminfo";
            Tr; 
                th class => "wc1", "Team Info"; 
                th ""; 
            end;
            Tr;
                td "Balance Teams:";
                td ( (defined $info->{balanceteams} && 
                              $info->{balanceteams} =~ m/true/i ) ? "Yes" : "No");
            end;
            Tr;
                td "Players Balance Teams:";
                td ( defined $info->{playersbalanceteams} && 
                             $info->{playersbalanceteams} ? "Yes" : "No");
            end;
            Tr;
                td "Friendly Fire:";
                td ($info->{friendlyfire} // "0%");
            end;
            Tr;
                td "Max Teams:";
                td ($info->{maxteams} // 1);
            end;
        end;
        
        #
        # Game Limits
        table class => "limits";
            Tr; 
                th class => "wc1", "Limits"; 
                th ""; 
            end;
            Tr;
                td "Time Limit:";
                td (($info->{timelimit} // 0). " min");
            end;
            Tr;
                td "Score Limit:";
                td ($info->{goalteamscore} // 0);
            end;
            Tr;
                td "Frag Limit:";
                td ($info->{fraglimit} // 0);
            end;
        end;
        
        #
        # Share options (copy fields)
        my $url = $self->{site_url}
                . "/"
                . $gamename
                . "/"
                . ( $self->to_ipv4_str($info->{ip}) // "0.0.0.0" )
                . ":"
                . ($info->{hostport} // 0);
        
        table class => "shareopts";
            Tr; 
                th class => "wc1", "Share";
                th ""; 
            end;
            Tr;
                td class => "tc1", "Link";
                td class => "tc2";
                    input type  => 'text', 
                          class => 'text', 
                          name => 'url', 
                          value => $url;
                end;
            end;
            Tr;
                td class => "tc1";
                    a href => "/json", 
                      title => "The url to access this server over the 333networks Json API", 
                      "Json API";
                end;
                td class => "tc2";
                    input type  => 'text', 
                          class => 'text', 
                          name  => 'url', 
                          value => $self->{site_url}
                                .  "/json/"
                                . $gamename
                                . "/"
                                . ( $self->to_ipv4_str($info->{ip}) // "0.0.0.0" )
                                . ":"
                                . ($info->{hostport} // 0);
                end;
            end;
            Tr;
                td "Forum Link";
                td;
                    textarea type  => 'textarea', 
                             class => 'text', 
                             rows => 3, 
                             name => 'paste';
                        txt "\[url=$url\]";lit "\n";
                        txt $info->{hostname} // "[unnamed $gamename server]";
                        lit "\n";
                        txt "\[/url\]";
                    end;
                end;
            end;
            Tr;
                td "HTML Code";
                td;
                    textarea type  => 'textarea', 
                             class => 'text', 
                             rows  => 3, 
                             name  => 'paste';
                        txt "<a href=\"$url\">";
                        lit "\n";
                        txt $info->{hostname} // "[unnamed $gamename server]";
                        lit "\n";
                        txt "</a>";
                    end;
                end;
            end;
        end; # share options
        
    end; # mainbox details
    $self->htmlFooter;
}

1;
