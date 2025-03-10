package MasterWebInterface::Handler::ServInfo;
use strict;
use warnings;
use utf8;
use Socket;
use TUWF ':html';
use POSIX 'strftime';
use Exporter 'import';

TUWF::register(
    qr{([\w]{1,20})/(\w{4}:\w{4}:\w{4}:\w{4}:\w{4}:\w{4}:\w{4}:\w{4}):(\d{1,5})} => \&show_server, #ipv6
    qr{([\w]{1,20})/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}):(\d{1,5})}              => \&show_server, #ipv4
    qr{([\w]{1,20})/([\w\.]{3,63}):(\d{1,5})}                                         => \&show_server, #domain name
);
 
#
# Display server information
#
################################################################################
sub show_server
{
    my ($self, $gamename, $addr, $port) = @_;
    
    # domain name check
    my $ip = $addr;
    if ($addr =~ m/[a-z]/ig )
    {
        # $addr holds a value that is a domain. try to resolve.
        my $packed_ip = gethostbyname($ip);
        $ip = inet_ntoa($packed_ip) if (defined $packed_ip);
    }
    
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
        
        # meta data
        my $img = (-e "$self->{root}/s/map/default/$gamename.jpg") 
            ? "/map/default/$gamename.jpg" : "/map/default/333networks.jpg";
        my $desc = "It seems the server you were looking for does not exist in our database, perhaps our search function may yield results? You tried to access ".($ip // "[no ip]")." in $gamename.";
        
        # otherwise not found in database, soft error page (no 404 status)
        $self->htmlHeader(title => 'Server not found', meta_desc => $desc, meta_img => $img);
        $self->htmlFilterBox(
            sel => 's', 
            fq => '', 
            ($gamename ? (gamename => $gamename) : () ),
        );

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
                    span class => "hilit";
                        txt ($addr // "");
                        if ($addr =~ m/[a-z]/ig )
                        {
                            txt " (";
                            txt ($ip // "[no ip]");
                            txt ")";
                        }
                    end;
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

    my $mapfig = "/map/default/333networks.jpg";
    my $mapfile = lc ($info->{mapname} // "");
    
    # some games may be merged gamename-wise
    my $gamenamedir = ($gamename =~ m/mohaa/) ? "mohaa" : $gamename;
    
    # if map figure exists, use it
    if (-e "$self->{root}/s/map/$gamenamedir/$mapfile.jpg") 
    {
        # map image
        $mapfig = "/map/$gamenamedir/$mapfile.jpg";
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
                 ? $info->{maptitle} : $mapname;

                
    my ($flag, $country) = $self->countryflag($info->{country} // "");

    #meta description
    my $desc  = "Address: ". ($info->{ip} // "0.0.0.0"). ":" . ($info->{hostport} // 0) . " ($country)
    Players: ". ($info->{numplayers} // 0) ."/". ($info->{maxplayers} // 0) ."
    GameType: " . ($info->{gametype} // "") . "
    Map: $maptitle";
    
    #
    # generate info page
    $self->htmlHeader(title => $info->{hostname} // "Server", meta_img => $mapfig, meta_desc => $desc);
    
    $self->htmlFilterBox(
        gamename => $gamename,
        sel => 's', 
        fq => '',
    );
    
    # serverinfo box
    div class => "mainbox detail";
        div class => "header";
            # server data flags in header (not country flags)
            div class => "serverflags";
                
                # uplink or manually added/through applet
                if ( $info->{f_direct} ) 
                { div class => "g"; div class => "direct", title => "This server uplinks directly to $self->{site_name}.", ""; end;}
                else
                { div class => "r"; div class => "manual", title => "This server was added through master synchronisation and does not uplink to $self->{site_name}.", ""; end;}
                
                # authenticated through secure/validate
                if ( $info->{f_auth} )
                { div class => "g"; div class => "authed",   title => "This server authenticated through the secure/validate challenge.", ""; end;}
                else
                { div class => "r"; div class => "noauthed", title => "This server failed the secure/validate challenge or did not reply.", ""; end;}
                
                # server blacklisted?
                if ( $info->{f_blacklist} )
                { div class => "r"; div class => "blacklist",   title => "This server is blacklisted for violating the $self->{site_name} Terms of Use or by request from the administrator.", ""; end;}
                else
                { div class => "g"; div class => "noblacklist", title => "This server is not blacklisted by $self->{site_name}.", ""; end;}
                
                if ( $info->{passworded} and $info->{passworded} =~ /(true|1)/i )
                { div class => "r"; div class => "passwd",   title => "This server requires a password to join.", ""; end;}
                else
                { div class => "g"; div class => "nopasswd", title => "This server is accessible for everybody.", ""; end;}
            end;    
            h1 title  => $info->{hostname} // "[unnamed $gamename server]",
                         $info->{hostname} // "[unnamed $gamename server]";   
        end;
        
        #
        # Map thumbnail and bot info
        #
        div class => "container";

            # find the correct thumbnail, otherwise game default, otherwise 333 default
            div class => "thumbnail";
                img src => $mapfig, 
                    alt => $mapfig, 
                    title => $mapname;
                span $maptitle;
            end;
            
            # added / last seen
            div class => "updatenote";
                span title => ("Server was added on ". strftime "%e %b %Y", gmtime ($info->{dt_added} // 0) );
                    
                    txt "information updated ";
                    my @t = gmtime( time - ( $info->{dt_serverinfo} // 0 ) );

                    my $diff;
                    $diff .= ($t[5]-70)*365 + $t[7] > 0 ? ( ($t[5]-70)*365 + $t[7])." days" : "" ; # years+days
                    
                    # if no years/days, add hours/minutes/seconds to display
                    if ( ($t[5]-70)*365 + $t[7] <= 0 )
                    {
                        $diff .= ($t[2] ? $t[2]."h" : ""); # hours
                        $diff .= ($t[1] ? $t[1]."m" : ""); # minutes
                        $diff .= ($t[0] ? sprintf "%02ds", $t[0] : ""); # seconds
                    }
                    
                    # output and coloring
                    if ( length $diff )
                    {
                        span class => ( ($t[5]-70 or $t[7]) ? "r" : ($t[2] ? "o" : "g") ), $diff;
                        txt " ago.";
                    }
                    else
                    {
                        span class => "g", "right now.";
                    }
                end; #span
            end; # updatenote
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
                    txt $info->{ip} // "0.0.0.0";
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
                td ($info->{adminemail} ? $info->{adminemail} : "-") ;
            end;
            
            # location data
            Tr;
                td class => "wc1", "Location:";
                td;
                    img class => "flag", src => "/flag/$flag.svg";
                    txt " ". $country;
                end;
            end;

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
        
        # disable stats that are considered irrelevant. can be re-enabled with "if (1)"
        if (0)
        {
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
        }
        
        #
        # JSON URL (code inactive)
        table class => "shareopts";
            Tr; 
                th;
                    a href => "http://333networks.com/json", title => "For more info, click to go to 333networks.com/json", "Json API";
                end;
            end;
            td;
                a href => ($self->{site_url} . "/json/" . $gamename . "/" . ($info->{ip} // "0.0.0.0") . ":" . ($info->{hostport} // 0) ),
                          ($self->{site_url} . "/json/" . $gamename . "/" . ($info->{ip} // "0.0.0.0") . ":" . ($info->{hostport} // 0) );
            end;
            
            if (0) # disable PNG banners because perfomance issues
            {
            Tr; 
                th;
                    txt "Server Banner:";
                end;
            end;
            td;
                a href => ($self->{site_url} . "/png/" . $gamename . "/" . ( $info->{ip} // "0.0.0.0" ) . ":" . ($info->{hostport} // 0)),
                          ($self->{site_url} . "/png/" . $gamename . "/" . ( $info->{ip} // "0.0.0.0" ) . ":" . ($info->{hostport} // 0));
            end;
            }
        end;
      
    end; # mainbox details
    $self->htmlFooter;
}

1;
