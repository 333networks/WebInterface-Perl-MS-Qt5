package MasterWebInterface::Handler::Servers;
use strict;
use utf8;
use TUWF ':html';
use Exporter 'import';

TUWF::register(
    qr{}                     => \&serverlist,
    qr{(s|adv)}              => \&serverlist,
    qr{(s|adv)/([\w]{0,20})} => \&serverlist,
);

#
# Generate a list of selected games in the database per game (arg: gamename)
#
sub serverlist 
{
    my($self, $adv, $gamename) = @_;
    
    # sorting, page
    my $f = $self->formValidate(
        {   get => 's', required => 0, default => 'gamename',enum => [ qw| hostname gamename country dt_added gametype numplayers mapname | ] },
        {   get => 'o', required => 0, default => 'a',enum      => [ 'a','d' ] },
        {   get => 'p', required => 0, default => 1,  template  => 'page',},
        {   get => 'q', required => 0, default => '', maxlength => 90 },
        
        # advanced search
        {   get => 'gamename', required => 0, default => '',  maxlength => 90 }, # gamename in advanced search
        {   get => 'gametype', required => 0, default => '',  maxlength => 90 }, # gametype
        {   get => 'hostname', required => 0, default => '',  maxlength => 90 }, # hostname (replaces q in advanced search)
        {   get => 'mapname',  required => 0, default => '',  maxlength => 90 }, # mapname
        {   get => 'country',  required => 0, default => '',  maxlength => 90 }, # country (code)
    );
    return $self->resNotFound if $f->{_err};
    
    # set correct gamename (form always overwrites url)
    $gamename = ( $f->{gamename} ? $f->{gamename} : $gamename);
    
    # load server list from database FIXME order of list, duplicates
    my ( $list, $np, $p ) = $self->dbServerListGet(
        sort => $f->{s}, 
        reverse  => $f->{o} eq 'd',
        search   => $f->{q},
        page     => $f->{p},
        results  => 50,
        updated  => $self->{window_time},
        gamename => $gamename,
        gametype => $f->{gametype},
        hostname => $f->{hostname},
        mapname  => $f->{mapname},
        country  => $f->{country},

        # don't show 333networks in default list, but show in advanced search by default
        !($gamename eq "333networks" or $f->{gamename} eq "333networks") ? ( nolist => "333networks") : (), 
    );
    
    # Write page  
    $self->htmlHeader(title => "Servers");
    
    # search box type: simple or advanced
    if ($adv eq 'adv')
    {
        # advanced filter box with additional search fields
        $self->htmlAdvancedFilterBox(
            sel => 's', 
            %{$f}, # previous parameters
            gamename => $gamename,
        );
    }
    else # $adv eq "adv"
    {
        # simple search box
        $self->htmlFilterBox(
            sel => 's', 
            ($gamename ? (gamename => $gamename) : () ),
            action => "/s/$gamename", 
            fq => $f->{q},
        );
    }
    
    # construct page URLs
    my $pageurl = "/$adv/$gamename?"
                . ( $adv eq "adv" ? "gamename=$f->{gamename}&gametype=$f->{gametype}&hostname=$f->{hostname}&mapname=$f->{mapname}&country=$f->{country}&o=$f->{o};s=$f->{s}" : "")
                . ( $adv eq "s"   ? "o=$f->{o};s=$f->{s};q=$f->{q}" : "");
    my $sorturl = "/$adv/$gamename?"
                . ( $adv eq "adv" ? "gamename=$f->{gamename}&gametype=$f->{gametype}&hostname=$f->{hostname}&mapname=$f->{mapname}&country=$f->{country}" : "")
                . ( $adv eq "s"   ? "q=$f->{q}" : "");
    
    #
    # server list
    $self->htmlBrowse(
        items    => $list,
        options  => $f,
        total    => $p,
        nextpage => [$p,50],
        pageurl  => $pageurl, #"/$adv/$gamename?o=$f->{o};s=$f->{s};q=$f->{q}",
        sorturl  => $sorturl, #"/$adv/$gamename?q=$f->{q}",
        class    => "serverlist",
        ($p <= 0) ? (footer => sub 
            {
                Tr;
                    td colspan => 6, class => 'tc2', 'No online servers found.';
                end 'tr';
            }) : (),
        header   => [
            [ '',             'country'     ],
            [ 'Server Name',  'hostname'    ],
            [ 'Game',         'gamename'    ],
            [ 'Gametype',     'gametype'    ],
            [ 'Players',      'numplayers'  ],
            [ 'Map',          'mapname'    ],
        ],
        row     => sub 
        {
            
            my($s, $n, $l) = @_;
            Tr $n % 2 ? (class => 's odd') : (class => 's');
            
                # country flag
                # TODO: advanced filter by country only
                my ($flag, $country) = $self->countryflag($l->{country});
                td class => "tc1", 
                   style => "background-image: url(/flag/$flag.svg);", 
                   title => $country, 
                   '';
                
                # server name (and defaults)
                my $ip = $l->{ip} // "0.0.0.0";
                my $hp = $l->{hostport} // 0;      
                my $gn = $l->{gamename} // "";
                td class => "tc2"; 
                    a href   => "/$gn/$ip:$hp", 
                      title  => $l->{hostname} // "[unnamed $gn server]",
                      $l->{hostname} // "[unnamed $gn server]"; 
                end;
                
                # gamename + icon
                if (-e "$self->{root}/s/icon32/$gn.png" ) 
                {
                    td class => "tc3 icon",
                       style => "background-image: url(/icon32/$gn.png);", 
                       title => $l->{label};
                        a href => "/$adv/$gn", "";
                    end;
                }
                else
                {
                    td $gn;
                }
                
                # game type (hover: raw, display: parsed)
                # TODO: advanced filter by gametype only
                td class => "tc4",
                    title => $l->{gametype}, 
                    $self->better_gametype($l->{gametype});
                
                # number of players / maximum players
                td class => "tc5"; 
                    txt $l->{numplayers} // 0; 
                    txt "/"; 
                    txt $l->{maxplayers} // 0; 
                end;
                
                # map title/name
                my $maplabel = ($l->{maptitle} && lc $l->{maptitle} ne "untitled" ? $l->{maptitle} : $l->{mapname});
                td class => "tc6", title => $maplabel // "---", $maplabel // "---";
            end;
        },
    );
    
    $self->htmlFooter;
}

1;
