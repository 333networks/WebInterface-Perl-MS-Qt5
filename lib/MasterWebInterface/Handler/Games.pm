package MasterWebInterface::Handler::Games;

use strict;
use utf8;

use TUWF ':html';
use Exporter 'import';

TUWF::register(
    qr{g}        => \&gamelist,
    qr{g(|/all)} => \&gamelist,
);

################################################################################
# LIST GAMES
# Generate a list of games in the database (arg: gamename)
################################################################################
sub gamelist 
{
    my ($self, $all) = @_;
    
    # process additional query information, such as order, sorting, page, etc
    my $f = $self->formValidate(
        { 
            get => 's', 
            required => 0, 
            default => 'num_total', 
            enum => [ qw| label gamename num_total | ] 
        },
        {
            get => 'o', 
            required => 0, 
            default => 'd', 
            enum => [ 'a','d' ] 
        },
        {
            get => 'p', 
            required => 0, 
            default => 1, 
            template => 'page'
        },
        {
            get => 'q', 
            required => 0, 
            default => '', 
            maxlength => 30 
        },
        { 
            get => 'r', 
            required => 0, 
            default => 50, 
            template => 'page' 
        }
    );
    return $self->resNotFound if $f->{_err};
    
    # load server list from database
    my($list, $np, $p) = $self->dbGameListGet(
        sort    => $f->{s}, 
        reverse => $f->{o} eq 'd',
        page    => $f->{p},
        search  => $f->{q},
        results => $f->{r},
        all     => $all,
        
    );
    
    #
    # page
    #
    
    $self->htmlHeader(title => "Browse Games");
    $self->htmlSearchBox(title => "Games", action => "/g/all", sel => 'g', fq => $f->{q});
    
    #
    # game list
    #
    
    # table url (full table or only active servers?)
    my $url = ($all) ? "/g/all" : "/g";
    $self->htmlBrowse(
        items    => $list,
        options  => $f,
        total    => $p,
        nextpage => [$p,$f->{r}],
        pageurl  => "$url?o=$f->{o};s=$f->{s};q=$f->{q}",
        sorturl  => "$url?q=$f->{q}",
        class    => "gamelist",
        (! $np and ! $all or $p <= 0) ? (footer => sub 
        {
            Tr $p % $f->{r} ? (class => 'odd') : ();
                td colspan => 3, class => 'tc2';
                    txt "No (more) games with active servers. Browse ";
                    a class => "link", href => "/g/all", "all game titles";
                    txt " instead.";
                end;
            end 'tr';
        }) : (),
        header   => [
            ['Release Title', 'label' ],
            ['Game', ''],
            ['Servers', 'num_total'    ],
        ],
        row     => sub 
        {
            my($s, $n, $l) = @_;
            
            my $gn = $l->{gamename} // "";
            my $lb = $l->{label}    // "";
            
            
            Tr $n % 2 ? (class => 's odd') : (class => 's');
            
                # label + link
                td class => "tc1"; 
                    a href => "/s/$gn", $lb; 
                end;
                
                # icon or gamename
                if (-e "$self->{root}/s/icon32/$gn.png" ) 
                {
                    td class => "tc2 icon", 
                       style => "background-image: url(/icon32/$gn.png);", 
                       title => $gn, 
                       '';
                }
                else
                {
                    td $gn;
                }
                
                # number of beacons / servers
                td title => ($l->{num_direct} // 0) . "/" . ($l->{num_total} // 0), 
                $l->{num_total} // 0;
            end;
        },
    );
  
    $self->htmlFooter;
}

1;
