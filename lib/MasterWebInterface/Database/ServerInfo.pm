package MasterWebInterface::Database::ServerInfo;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT = qw| dbGetServerInfo dbGetPlayerInfoList |;

## get server details for list of servers (gamename/all/recent)
sub dbGetServerInfo 
{
  my $s = shift;
  my %o = @_;
  
  my %where = (
    $o{ip}        ? (  'ip = ?'           => $o{ip})       : (),
    $o{port}      ? (  'queryport = ?'    => $o{port})     : (),
    $o{hostport}  ? (  'hostport = ?'     => $o{hostport}) : (),
  );

  return $s->dbAll( q|SELECT * FROM serverlist
                      LEFT JOIN serverinfo ON serverlist.id = serverinfo.sid
                      !W LIMIT 1|, \%where );
}


## get player details for one particular server
sub dbGetPlayerInfoList 
{
  my $s = shift;
  my %o = (sort => '', @_ );
  
  my %where = (
    $o{sid} ? ( 'sid = ?' => $o{sid})    : (),
  );
  
  my @select = ( qw| name team frags mesh skin face ping | );

  return $s->dbAll( q|SELECT * FROM playerinfo !W ORDER BY team, name|, \%where );
}

1;
