#!/usr/bin/perl
package MasterWebInterface;
use strict;
use warnings;
use Data::Dumper 'Dumper';
use Cwd 'abs_path';

our $ROOT;
BEGIN { ($ROOT = abs_path $0) =~ s{/s/masterinterface.pl$}{}; }
use lib $ROOT.'/lib';
use TUWF;

# get settings and add these to the TUWF object
our %S = (root => $ROOT);
require "$ROOT/data/settings.pl";


$TUWF::OBJ->{$_} = $S{$_} for (keys %S);

# TUWF options
TUWF::set(
  logfile               => "$ROOT/log/TUWF.log",
  mail_from             => $S{email},
  db_login              => $S{db_login},
  validate_templates => { # input templates
    page  => { template => 'uint', max => 1000 },
  },
  log_queries           => 0,
  debug                 => 1,
);

#add %S from web-config.pl to OBJ
$TUWF::OBJ->{$_} = $S{$_} for (keys %S);

TUWF::load_recursive('MasterWebInterface');
TUWF::run();

