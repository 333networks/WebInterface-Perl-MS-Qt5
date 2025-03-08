package MasterWebInterface::Database::Servers;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT = qw| dbServerListGet |;

################################################################################
## get the serverlist
################################################################################
sub dbServerListGet {
  my $s = shift;
  my %o = ( page => 1, 
            results => 50, 
            @_ 
  );
    
  my %where = (
    # gamename and char are "all" or value
    $o{gamename} !~ /all/ ? ('serverlist.gamename = ?' => $o{gamename})       : (),
    $o{updated}  ? ('dt_updated > ?'                => (time-$o{updated})) : (),
    #$o{gamename} ? ('serverlist.gamename = ?'       => $o{gamename})       : (),
    $o{nolist}   ? ('serverlist.gamename <> ?'      => $o{nolist})         : (),
    $o{search}   ? ('LOWER(hostname) LIKE LOWER(?)' => "%$o{search}%")     : (),
    $o{popserv}  ? ('numplayers > ?'                => 0)                  : (),
    $o{utdemo}   ? ('gamever = ?'                   => '348')              : (),
    
    #advanced search
    $o{hostname} ? ('LOWER(hostname) LIKE LOWER(?)' => "%$o{hostname}%")     : (),
    $o{gametype} ? ('LOWER(gametype) LIKE LOWER(?)' => "%$o{gametype}%")     : (),
    $o{mapname}  ? ('(LOWER(mapname) LIKE LOWER(?) OR LOWER(maptitle) LIKE LOWER(?))' => ["%$o{mapname}%", "%$o{mapname}%"]) : (),
    $o{country}  ? ('country         LIKE UPPER(?)' => $o{country})        : (),
    
    # sanity check for unresponsive servers or faulty queries tools, except ST:Bcommander which /is/ faulty by default
    $o{gamename} !~ /bcommander/ ? ('hostport > ?' => 0) : (),
  );
  
  my @select = ( qw| id ip hostport hostname serverlist.gamename country numplayers maxplayers maptitle mapname gametype dt_added label dt_updated| );

  my $order = sprintf {
    hostname    => 'hostname %s',
    gamename    => 'serverlist.gamename %s, gametype',
    country     => 'country %s',
    dt_added    => 'dt_added %s',
    gametype    => 'gametype %s, mapname',
    numplayers  => 'numplayers %s, maxplayers',
    maptitle    => 'maptitle %s',
    mapname     => 'mapname %s',
  }->{ $o{sort} // 'dt_added' }, $o{reverse} ? 'DESC' : 'ASC';
  
  my($r, $np) = $s->dbPage(\%o, q|
    SELECT !s FROM serverlist
      LEFT JOIN serverinfo ON serverlist.id = serverinfo.sid
      LEFT JOIN gameinfo ON serverlist.gamename = gameinfo.gamename
      !W
      ORDER BY !s |,
    join(', ', @select), \%where, $order
  );

  my $p = $s->dbAll( q|
    SELECT COUNT(*) AS num
    FROM serverlist
    LEFT JOIN serverinfo ON serverlist.id = serverinfo.sid
    !W|, \%where,
  )->[0]{num};
  return wantarray ? ($r, $np, $p) : $r;

}


1;
