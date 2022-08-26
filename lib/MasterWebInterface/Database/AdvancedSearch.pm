package MasterWebInterface::Database::AdvancedSearch;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT = qw| dbGetGameTypes dbGetCountries |;

sub dbGetGameTypes 
{
  my $s = shift;
  my %o = ( @_ );
    
  my %where = (
    # gamename and char are "all" or value
    $o{gamename}          ? ('serverlist.gamename = ?'       => $o{gamename})       : (),
    ('gametype IS NOT NULL' => ""),

    # do not filter by country. the gametype can still exist for that game while there are no online servers for it.    
    #$o{country}           ? ('country         LIKE UPPER(?)' => $o{country})         : (),
  );
  
  return $s->dbAll( q|
    SELECT DISTINCT gametype FROM serverlist
      LEFT JOIN serverinfo ON serverlist.id = serverinfo.sid
      !W ORDER BY lower(gametype) ASC|,
    \%where,
  );
}

sub dbGetCountries 
{
  my $s = shift;
  my %o = ( @_ );
    
  my %where = (
    $o{gamename}          ? ('serverlist.gamename = ?'       => $o{gamename})       : (),
    $o{hostname}          ? ('LOWER(hostname) LIKE LOWER(?)' => "%$o{hostname}%")     : (),
    $o{mapname}           ? ('(LOWER(mapname) LIKE LOWER(?) OR LOWER(maptitle) LIKE LOWER(?))' => ["%$o{mapname}%", "%$o{mapname}%"]) : (),
    $o{gametype}          ? ('LOWER(gametype) LIKE LOWER(?)' => $o{gametype})         : (),

    ("COUNTRY IS NOT NULL" => ""),
  );
  
  return $s->dbAll( q|
    SELECT DISTINCT country FROM serverlist
      LEFT JOIN serverinfo ON serverlist.id = serverinfo.sid
      !W ORDER BY lower(country) ASC|,
    \%where,
  );
}

1;
