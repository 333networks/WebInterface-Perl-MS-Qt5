package MasterWebInterface::Util::AdvancedFilterBox;
use strict;
use warnings;
use utf8;
use TUWF ':html', 'xml_escape';
use Geography::Countries;
use Exporter 'import';
our @EXPORT = qw| htmlAdvancedFilterBox |;
use Data::Dumper 'Dumper';

# display an advanced filter box with dropdown/search fields
# options:
#   sel: select [g]ames or [s]ervers link (filter only works for servers anyway)
#   dropdown selects: gamename, gametype, country
#   text fields: hostname, mapname/maptitle
# user must first select a gamename before other options become available. 
# gametype and country options are selected from database on available criteria.
# TODO: also list servers that expired or timed out (checkbox?)
# TODO: allow searching by IP, in combination with expired servers (and sanity check in javascript?)
sub htmlAdvancedFilterBox 
{
    my ($self, %opt) = @_;
    
    div class => 'mainbox';
        div class => "header";
            h1 "Advanced Filter";
            p class => "alttitle";
                txt "Filter for servers in all titles that are currently online. ";
                txt "Advanced Filter is in Beta. Please report bugs on our ";
                a href => "https://333networks.com/contact", "discord";
                txt ".";
            end;
        end;
        
        if (0)
        {
        div class => "codeblock";
            p "No worries, Darkelarious is debugging an issue right now. Please ignore this code block.";
            pre;
                txt Dumper \%opt;
            end;
        end;
        }

        # advanced filter form        
        form action => "/adv", 'accept-charset' => 'UTF-8', method => 'get', class => "advancedfilter";
            fieldset class => 'advanced';
                a href => '/g',    $opt{sel} eq 'g' ? (class => 'sel') : (), 'Games';
                a href => '/s',    $opt{sel} eq 's' ? (class => 'sel') : (), 'Servers';
                
                # parameters for error fields;
                my $gameselect = "this game";
                
                # table with all filter options
                table;
                
                    Tr; # gamename
                        td class => "desc", "Game: ";
                        td class => "param";
                            Select onchange => "this.form.submit()", name => "gamename", id => "gamename";
                                option class => "selection", value => "", "Select...";
                                option value => $_->{gamename}, ($_->{gamename} eq $opt{gamename} ? (selected => ($gameselect = $_->{label})) : () ), 
                                    $_->{label} for $self->dbGameListGet(sort => "gamename" )->@*;
                            end; #select
                        end;
                    end;
                    
                    Tr; # gametype
                        td class => "desc", "Gametype: ";
                        td class => "param";
                            # don't list gametypes until a gamename has been selected
                            if ( ! $opt{gamename} )
                            {
                                Select onchange => "this.form.submit()", name => "gametype", id => "gametype", disabled => "true";
                                
                                    # if a gametype is still provided
                                    if ( $opt{gametype} )
                                    {
                                        option value => $opt{gametype}, disabled => 1, selected => 1, $opt{gametype};
                                    }
                                    else
                                    {
                                        option class => "selection", value => "", "Select a game title first";
                                    }
                                end; # select
                            }
                            else
                            {
                                Select onchange => "this.form.submit()", name => "gametype", id => "gametype";
                                    option value => "", "All game types";
                                    my $valid_gt = 0;
                                    my %seen = ();                                    
                                    for ($self->dbGetGameTypes(%opt)->@*)
                                    {
                                        # if not yet seen, add option and mark "seen"
                                        if (! $seen{lc $_->{gametype}} )
                                        {
                                            option value => $_->{gametype}, (lc $_->{gametype} eq lc $opt{gametype} ? (selected => ($valid_gt = 1)) : () ), $_->{gametype} ;
                                            $seen{lc $_->{gametype}} = 1;
                                        }
                                    }
                                    
                                    # display incorrect values with grayed-out option
                                    if (not $valid_gt and $opt{gametype})
                                    {
                                        option value => $opt{gametype}, disabled => 1, selected => 1, $opt{gametype};
                                    }
                                    
                                end; # select
                                
                                # notify user of incorrect option
                                if (not $valid_gt and $opt{gametype})
                                {
                                    br;
                                    span class => "errorsel", "The gametype \"$opt{gametype}\" does not exist for $gameselect. Please select a valid gametype.";
                                }
                            }
                        end;
                    end;

                    Tr; # hostname
                        td class => "desc", "Servername: ";
                        td class => "param";
                            input type => 'text', name => 'hostname', id => 'hostname', class => 'text', value => $opt{hostname} // "";
                        end;
                    end;

                    
                    Tr; # mapname
                        td class => "desc", "Active map: ";
                        td class => "param";
                            input type => 'text', name => 'mapname', id => 'mapname', class => 'text', value => $opt{mapname} // "";
                        end;
                    end;
                    
                    Tr; # location / country
                        td class => "desc", "Country: ";
                        td class => "param";
                           # don't list gametypes until a gamename has been selected
                            if ( ! $opt{gamename} )
                            {
                                Select onchange => "this.form.submit()", name => "country", id => "country", disabled => "true";
                                
                                # if a country is still provided
                                if ( $opt{country} )
                                {
                                    option value => $opt{country}, disabled => 1, selected => 1, "($opt{country}) ".(my $c = country $opt{country});
                                }
                                else
                                {
                                    option class => "selection", value => "", "Select a game title first";
                                }
                                end; # select
                            }
                            else
                            {
                                Select onchange => "this.form.submit()", name => "country", id => "country";
                                    option class => "selection", value => "", "Everywhere";
                                    my $valid_c = 0;
                                    option value => $_, ($_ eq $opt{country} ? (selected => ($valid_c = 1)) : () ), 
                                        "($_) ".(my $c = country $_) for map $_->{country}, $self->dbGetCountries(%opt)->@*;
                                    
                                    # display incorrect values with grayed-out option
                                    if (not $valid_c and $opt{country})
                                    {
                                        option value => $opt{country}, disabled => 1, selected => 1, "($opt{country}) ".(my $c = country $opt{country});
                                    };
                                end; # select
                                
                                # notify user of incorrect option
                                if (not $valid_c and $opt{country})
                                {
                                    br;
                                    span class => "errorsel";
                                        txt "No servers in ";
                                        txt (my $c = country $opt{country});
                                        txt " found that meet the search criteria.";
                                    end;
                                }
                            }
                        end;
                    end;
                    
                    Tr; # submit
                        td "";
                        td;
                            input type => 'submit', class => 'submit', value => 'Filter';
                        end;
                    end;
                end; # table
                
            end 'fieldset';
        end; # form
        
        # return to simple filter/layout
        div class => "simpleadvanced";
            a href => $opt{gamename} ? "/s/$opt{gamename}" : "/s";
                txt "simple filter ";
                lit "\x{25B4}";
            end;
        end;
    
    end 'div';
}

1;
