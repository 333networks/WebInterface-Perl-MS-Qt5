package MasterWebInterface::Util::Misc;
use strict;
use warnings;
use TUWF ':html';
use POSIX 'strftime';
use Exporter 'import';
use Geography::Countries;
use Unicode::Normalize 'NFKD';
our @EXPORT = qw| date_new timeformat countryflag |;

# time formatting for when a server was added
sub date_new 
{
  my ($s, $d) = @_;
  return (strftime "%a %H:%M", gmtime $d); # no seconds
}

# time formatting for when a server was added / last updated
sub timeformat 
{
  my ($self, $time) = @_;
  my @t = gmtime($time);
  my $r = "";

  # parse into d HH:mm:SS format
  if ($t[7]){$r .= $t[7]."d "}
  if ($t[2]){$r .= ($t[2] > 9) ? $t[2].":" : "0".$t[2].":" }
  if ($t[1]){$r .= ($t[1] > 9) ? $t[1].":" : "0".$t[1].":" } else {$r .= "00:";}
  if ($t[0]){$r .= ($t[0] > 9) ? $t[0] : "0".$t[0]         } else {$r .= "00";}
  
  return $r;
}

# returns flag, country name
sub countryflag 
{
  my ($self, $c) = @_;
  my $flag = ($c ? lc $c : 'earth');
  my $coun = $c ? ( $c eq 'EU' ? 'Europe' : country $c ) : 'Earth' ;
  return $flag, $coun;  
}

1;
