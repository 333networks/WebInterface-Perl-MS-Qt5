package MasterWebInterface::Util::FilterBox;
use strict;
use warnings;
use utf8;
use TUWF ':html', 'xml_escape';
use Exporter 'import';
our @EXPORT = qw| htmlFilterBox |;

# generates a filter box, arguments:
# title  => games/ (game) servers
# action => form action
# sel    => g or s selected
# fq     => form query string
sub htmlFilterBox
{
    my($self, %opt) = @_;
    
    div class => 'mainbox';
        div class => "header";
            h1 "Browse Servers";
            p class => "alttitle", "An overview of games titles and servers that are currently online.";
        end;
        
        # filter box
        form action => $opt{gamename} ? "/s/$opt{gamename}" : "/s", 'accept-charset' => 'UTF-8', method => 'get';
            fieldset class => 'simple';
                a href => '/g',    $opt{sel} eq 'g' ? (class => 'sel') : (), 'Games';
                a href => '/s',    $opt{sel} eq 's' ? (class => 'sel') : (), 'Servers';
                input type => 'text', name => 'q', id => 'q', class => 'text', value => $opt{fq} || 'filter...';
                input type => 'submit', class => 'submit', value => 'submit';
            end 'fieldset';
        end; # form

        div class => "simpleadvanced";
            a href => $opt{gamename} ? "/adv/$opt{gamename}" : "/adv";
                txt "advanced server filter ";
                lit "\x{25BE}";
            end;
        end;
    end 'div'; # mainbox
}

1;
