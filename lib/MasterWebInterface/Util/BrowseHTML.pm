package MasterWebInterface::Util::BrowseHTML;
use strict;
use warnings;
use utf8;
use TUWF ':html', 'xml_escape';
use Exporter 'import';
use POSIX 'ceil';
our @EXPORT = qw| htmlSearchBox htmlBrowse htmlBrowseNavigate |;

# generates a search box, arguments:
# title  => games/ (game) servers
# action => form action
# sel    => g or s selected
# fq     => form query string
sub htmlSearchBox
{
    my($self, %opt) = @_;
    
    div class => 'mainbox';
        div class => "header";
            h1 "Browse $opt{title}";
            p class => "alttitle", "An overview of games titles and servers that are currently online.";
        end;
        
        # search box
        form action => $opt{action}, 'accept-charset' => 'UTF-8', method => 'get';
            fieldset class => 'search';
                a href => '/g',    $opt{sel} eq 'g' ? (class => 'sel') : (), 'Games';
                a href => '/s',    $opt{sel} eq 's' ? (class => 'sel') : (), 'Servers';
                input type => 'text', name => 'q', id => 'q', class => 'text', 
                    value => $opt{fq} || 'search...';
                input type => 'submit', class => 'submit', value => 'submit';
            end 'fieldset';
            
            div class => "dropdown";
                a href => "#", onclick => "toggleAdvanced()";
                    txt "advanced search ";
                    lit "\x{25BE}";
                end;
            end;
            
            fieldset id => 'advancedsearch';
                #input type => 'text', name => 'aq', class => 'text', value => '';
                #input type => 'submit', class => 'submit', value => 'submit';
                txt "Patience, young one. With time, advanced search options will become available to you.";
            end;
        end;
        
    end 'div'; # mainbox
}

# generates a browse box, arguments:
#  items    => arrayref with the list items
#  options  => hashref containing at least the keys s (sort key), o (order) and p (page)
#  nextpage => whether there's a next page or not
#  sorturl  => base URL to append the sort options to (if there are any sortable columns)
#  pageurl  => base URL to append the page option to
#  class    => classname of the mainbox
#  header   =>
#   can be either an arrayref or subroutine reference,
#   in the case of a subroutine, it will be called when the header should be written,
#   in the case of an arrayref, the array should contain the header items. Each item
#   can again be either an arrayref or subroutine ref. The arrayref would consist of
#   two elements: the name of the header, and the name of the sorting column if it can
#   be sorted
#  row      => subroutine ref, which is called for each item in $list, arguments will be
#   $self, $item_number (starting from 0), $item_value
#  footer   => subroutine ref, called after all rows have been processed
# Mostly written by Yorhel --> https://g.blicky.net/vndb.git/tree/COPYING
sub htmlBrowse 
{
    my($self, %opt) = @_;

    # get options
    $opt{sorturl} .= $opt{sorturl} =~ /\?/ ? ';' : '?' if $opt{sorturl};

    # top navigation
    $self->htmlBrowseNavigate($opt{pageurl}, $opt{options}{p}, $opt{nextpage}, 't') if $opt{pageurl};

    div class => 'mainbox browse'.($opt{class} ? ' '.$opt{class} : '');
        table class => 'stripe';

        # header
        thead;
            Tr;
                if(ref $opt{header} eq 'CODE') 
                {
                    $opt{header}->($self);
                }
                else 
                {
                    for(0..$#{$opt{header}}) 
                    {
                        if(ref $opt{header}[$_] eq 'CODE') 
                        {
                            $opt{header}[$_]->($self, $_+1);
                        } 
                        elsif ($opt{simple}) 
                        {
                            td class => $opt{header}[$_][3]||'tc'.($_+1), $opt{header}[$_][2] ? (colspan => $opt{header}[$_][2]) : ();
                                if($opt{header}[$_][1]) 
                                {
                                    lit qq|<a href="$opt{sorturl}o=d;s=$opt{header}[$_][1]">$opt{header}[$_][0]</a>|;
                                } 
                                else 
                                {
                                    txt $opt{header}[$_][0];
                                }
                            end;          
                        } 
                        else
                        {
                            td class => $opt{header}[$_][3]||'tc'.($_+1), $opt{header}[$_][2] ? (colspan => $opt{header}[$_][2]) : ();
                                if ( $opt{options}{s} eq $opt{header}[$_][1] )
                                { # active sort
                                    if ( $opt{options}{o} eq 'a' )
                                    {
                                        a href => "$opt{sorturl}o=d;s=$opt{header}[$_][1]";
                                            lit $opt{header}[$_][0];
                                            lit " \x{25B4}";
                                        end;
                                    }
                                    else
                                    { # eq 'd'
                                        a href => "$opt{sorturl}o=a;s=$opt{header}[$_][1]";
                                            lit $opt{header}[$_][0];
                                            lit " \x{25BE}";
                                        end;
                                    }
                                }
                                else
                                { # passive sort options
                                    a href => "$opt{sorturl}o=d;s=$opt{header}[$_][1]";
                                        lit $opt{header}[$_][0];
                                    end;
                                }
                            end;
                        }
                    }
                }
            end;
        end 'thead';

        # footer
        if($opt{footer}) 
        {
            tfoot;
                $opt{footer}->($self);
            end;
        }

        # rows
        $opt{row}->($self, $_+1, $opt{items}[$_]) for 0..$#{$opt{items}};

        end 'table';
    end 'div';

    # bottom navigation
    $self->htmlBrowseNavigate($opt{pageurl}, $opt{options}{p}, $opt{nextpage}, 'b') if $opt{pageurl};
}


# creates next/previous buttons (tabs), if needed
# Arguments: page url, current page (1..n), nextpage (0/1 or [$total, $perpage]), alignment (t/b), noappend (0/1)
# Mostly written by Yorhel --> https://g.blicky.net/vndb.git/tree/COPYING
sub htmlBrowseNavigate {
  my($self, $url, $p, $np, $al, $na) = @_;
  my($cnt, $pp) = ref($np) ? @$np : ($p+$np, 1);
  return if $p == 1 && $cnt <= $pp;

  $url .= $url =~ /\?/ ? ';p=' : '?p=' unless $na;

  my $tab = sub {
    my($left, $page, $label) = @_;
    li $left ? (class => 'left') : ();
     a href => $url.$page; lit $label; end;
    end;
  };
  my $ell = sub {
    li class => 'ellipsis'.(shift() ? ' left' : '');
     b '⋯';
    end;
  };
  my $nc = 5; # max. number of buttons on each side

  ul class => 'maintabs browsetabs ' . ($al eq 't' ? 'notfirst' : 'bottom');
   $p > $nc and ref $np and $tab->(1, 1, '&laquo; first');
   $p > $nc and ref $np and $ell->(1);
   $p > $_  and ref $np and $tab->(1, $p-$_, $p-$_) for (reverse 1..($nc>$p-1?$p-1:$nc-1));
   $p > 1               and $tab->(1, $p-1, '&lsaquo; previous');

   my $l = ceil($cnt/$pp)-$p+1;
   $l > $nc and $tab->(0, $l+$p-1, ('last').' &raquo;');
   $l > $nc and $ell->(0);
   $l > $_  and $tab->(0, $p+$_, $p+$_) for (reverse 1..($nc>$l-1?$l-1:$nc-1));
   $l > 1   and $tab->(0, $p+1, ('next').' &rsaquo;');
  end 'ul';
}

1;
