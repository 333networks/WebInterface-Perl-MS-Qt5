package MasterWebInterface::Database::Games;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT = qw| dbGameListGet dbGetGameDesc |;

# Get list of games
sub dbGameListGet 
{
    my $s = shift;
    my %o = (
        page    => 1, 
        results => 50, 
        sort    => '', 
        @_
    );
    
    # search criteria
    my %where = (
        $o{search} ? ('lower(label) LIKE lower(?)' => "%$o{search}%") : (),
        $o{search} ? ('lower(label) LIKE lower(?) OR lower(gamename) LIKE lower(?)' => ["%$o{search}%","%$o{search}%"]) : (),
        
        
        #$o{search}            ? ('LOWER(hostname) LIKE LOWER(?) OR LOWER(maptitle) LIKE LOWER(?) OR LOWER(mapname) LIKE LOWER(?)' => ["%$o{search}%", "%$o{search}%", "%$o{search}%"])     : (),
        
        
        !$o{all}   ? (             'num_total > ?' => 0)              : (),
    );
    
    # what to get from db
    my @select = ( 
        qw| label gamename num_direct num_total |
    );
    
    # sort order
    my $order = sprintf {
        label       => 'label %s',
        gamename    => 'gamename %s',
        num_total   => 'num_total %s',
    }->{ $o{sort}||'num_total' }, $o{reverse} ? 'DESC' : 'ASC';
    
    # query
    my($r, $np) = $s->dbPage(
        \%o, 
        q| SELECT !s FROM gameinfo !W ORDER BY !s|,
        join(', ', @select), 
        \%where, 
        $order
    );
    
    # page numbering
    my $p = $s->dbAll( 
        q| SELECT COUNT(*) AS num FROM gameinfo !W|, 
        \%where,
    )->[0]{num};
    
    return wantarray ? ($r, $np, $p) : $r;
}

# Get description for a game by gamename
sub dbGetGameDesc 
{
    my ($self, $gn) = @_;
    return $self->dbAll("SELECT label FROM gameinfo WHERE gamename = ? LIMIT 1", $gn)->[0]{label};
}

1;
