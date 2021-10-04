#!/usr/bin/perl

use strict;
use warnings;
use AnyEvent;
use DBI;
use LWP::Simple;
use JSON;
use Data::Dumper 'Dumper';
$|++;

# intro
print "Looking up IPs to countries using ip-api.com.\n";

# open db
my $dbpath = "dbi:SQLite:dbname=../data/masterserver.db";
my $dbh = DBI->connect($dbpath, '', '') or die "Cannot connect: $DBI::errstr\n";

# loop counter
my $index = -1;

# loop
my $cv = AnyEvent->condvar;

# send out heartbeats
my $timer = AnyEvent->timer (
    after     => 0, # seconds
    interval  => 10, # seconds
    cb        => sub 
    {
        my $next = $dbh->selectall_arrayref(
            "SELECT id, ip FROM serverlist ".
            "LEFT JOIN serverinfo ON serverlist.id = serverinfo.sid ".
            "WHERE id > ? ".
            "AND sid > 0 ".
            "AND country IS NULL ".
            "ORDER BY id ASC ".
            "LIMIT 1",
            undef,
            $index
        )->[0];

        # get country code
        if ( $next->[0] && $next->[0] >= 0)
        {
            # parse
            my $id   = $next->[0];
            my $addr = $next->[1];
            
            if ($addr eq "::1")
            {
                #print "skip ::1\n";
                $index = $id;
                return;
            }
            
            # get country data from API (throttle 45 requests per min)
            my $lwp = get("http://ip-api.com/json/$addr");
            my $data = decode_json $lwp;
            
            # insert in database
            if ( $data->{countryCode} )
            {
                $dbh->do(
                    "UPDATE serverinfo ".
                    "SET country = ? ".
                    "WHERE sid IN (".
                    "SELECT id FROM serverlist ".
                    "WHERE ip = ?)",
                    undef, $data->{countryCode}, $addr
                );
                
                print "$id\t$data->{countryCode}\t $addr\t$data->{query}\n";
            }
            else 
            {
                print "skip $id\t$addr\n";
                print Dumper $data;
            }
            
            # update index
            $index = $id;
        }
        else
        {
            # cycle complete, restart to re-read inserted serverinfo rows
            $index = -1;
        }
    },
);



$cv->recv;

1;
