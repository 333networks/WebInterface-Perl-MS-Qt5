package MasterWebInterface::Util::AddressFormat;
use strict;
use warnings;
use TUWF ':html';
use Exporter 'import';
our @EXPORT = qw| from_addr_str 
                  to_ipv4_str |;

################################################################################
# parse incoming addresses to IPv6 type used by MasterServer-Qt5 and port
# parses IPv4 to ::ffff:0.0.0.0 and port
# this is only a semi-sanity check -- invalid values (like port > 65535) 
# are ignored since they will simply not be found in the database.
################################################################################
sub from_addr_str {
  my ($self, $str_addr) = @_;
  my ($ip, $port);
  
  # ::ffff:127.0.0.1:7778
  if ($str_addr =~ /^::ffff:\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d{1,5}$/)
  {
    # ipv4 in ipv6 format is already in the correct format
    return ($ip, $port) = $str_addr =~ m/^(::ffff:\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}):(\d{1,5})$/;
  }
  
  # ipv6 (without leading ::) and trailing :7778 / port
  if ($str_addr =~ /^\w{4}:\w{4}:\w{4}:\w{4}:\w{4}:\w{4}:\w{4}:\w{4}:\d{1,5}$/)
  {
    # ipv6 already in the correct format
    return ($ip, $port) = $str_addr =~ m/^(\w{4}:\w{4}:\w{4}:\w{4}:\w{4}:\w{4}:\w{4}:\w{4}):(\d{1,5})$/;
  }
  
  # ipv4 (127.0.0.1:7778)
  if ($str_addr =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d{1,5}$/)
  { 
    # rewrite to ::ffff:127.0.0.1
    ($ip, $port) = $str_addr =~ m/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}):(\d{1,5})$/;
    return ("::ffff:".$ip, $port);
  }
  
  # failure
  return ("0.0.0.0", 0);
}

# write ::ffff:0.0.0.0 to 0.0.0.0 format if possible
# return ipv6 addresses untouched
sub to_ipv4_str 
{
  my ($self, $str_addr) = @_;
  $str_addr =~ s/^::ffff://;
  return $str_addr;
}

1;
