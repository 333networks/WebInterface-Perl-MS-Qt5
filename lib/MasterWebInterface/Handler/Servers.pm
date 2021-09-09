package MasterWebInterface::Handler::Servers;
use strict;
use utf8;
use TUWF ':html';
use Exporter 'import';

TUWF::register(
    qr{}                        => \&serverlist,
    qr{s}                       => \&serverlist,
    qr{s/(.[\w]{1,20})}         => \&serverlist,
);

################################################################################
# List servers
# Generate a list of selected games in the database per game (arg: gamename)
################################################################################
sub serverlist 
{
    my($self, $gamename) = @_;
    $gamename = "all" unless $gamename;
    
    # sorting, page
    my $f = $self->formValidate(
        {
            get => 's',
            required => 0,
            default => 'gamename',
            enum => [ qw| hostname gamename country dt_added gametype numplayers mapname | ] 
        },
        {
            get => 'o', 
            required => 0, 
            default => 'a', 
            enum => [ 'a','d' ] 
        },
        {
            get => 'p', 
            required => 0, 
            default => 1, 
            template => 'page',
        },
        {
            get => 'q', 
            required => 0, 
            default => '', 
            maxlength => 90 
        },
        { 
            get => 'r', 
            required => 0, 
            default => 50, 
            template => 'page' 
        },
        { 
            get => 'g', 
            required => 0, 
            default => '',  
            maxlength => 90 
        },
    );
    return $self->resNotFound if $f->{_err};
    
    # load server list from database
    my ( $list, $np, $p ) = $self->dbServerListGet(
        sort => $f->{s}, 
        reverse  => $f->{o} eq 'd',
        gamename => $gamename,
        search   => $f->{q},
        page     => $f->{p},
        updated  => $self->{window_time},
        results  => $f->{r},
        gametype => $f->{g},
        # don't show 333networks in default list
        $gamename ne "333networks" ? ( nolist => "333networks") : (), 
    );
    
    # game name description in title
    my $gn_desc = $self->dbGetGameDesc($gamename) // $gamename;
    
    #
    # page 
    #
    
    # Write page  
    $self->htmlHeader(title => "Browse $gn_desc game servers");
    $self->htmlSearchBox(
        title => "$gn_desc Servers", 
        action => "/s/$gamename", 
        sel => 's', 
        fq => $f->{q}
    );

    
    #
    # server list
    $self->htmlBrowse(
        items    => $list,
        options  => $f,
        total    => $p,
        nextpage => [$p,$f->{r}],
        pageurl  => "/s/$gamename?o=$f->{o};s=$f->{s};q=$f->{q}",
        sorturl  => "/s/$gamename?q=$f->{q}",
        class    => "serverlist",
        ($p <= 0) ? (footer => sub 
            {
                Tr;
                    td colspan => 6, class => 'tc2', 'No online servers found';
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
                my ($flag, $country) = $self->countryflag($l->{country});
                td class => "tc1", 
                   style => "background-image: url(/flag/$flag.svg);", 
                   title => $country, 
                   '';
                
                # server name
                my $ip = $self->to_ipv4_str($l->{ip});
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
                        a href => "/s/$gn", "";
                    end;
                }
                else
                {
                    td $gn;
                }
                
                # game type (hover: raw, display: parsed)
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
