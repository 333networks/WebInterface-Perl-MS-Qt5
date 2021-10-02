package MasterWebInterface::Util::Layout;
use strict;
use warnings;
use TUWF ':html';
use Exporter 'import';
our @EXPORT = qw| htmlHeader htmlFooter |;

################################################################################
# page header
#   options: title, noindex
################################################################################
sub htmlHeader 
{
    my($self, %o) = @_;
    
    # CSS override: allow passing of style from GET --> ?style=classic
    my $style = $self->{style};
    
    # rotate styles for different occasions.
    my @dt = localtime(time);
    # specify dates [m/d] = styles
    if ($dt[4] == 2  && $dt[3] == 31) {$style = "april";} # 31 mar and 1 apr
    if ($dt[4] == 3  && $dt[3] ==  1) {$style = "april";}
    if ($dt[4] == 9  && $dt[3] >=  1) {$style = "halloween";}
    if ($dt[4] == 11 && $dt[3] >=  7) {$style = "xmas";}    
    
    if (my $overrideStyle = $self->reqParam("style") ) 
    {
        # default to custom style if specified option doesn't exist
        $style = $overrideStyle;
    }
    
    # default to default style if specified option does not exist
    $style = ( -e "$self->{root}/s/style/$style" ) ? $style : $self->{style};
    
    html lang => "en";
        head;
            title "$o{title} :: $self->{site_name} masterserver";
            Link type => 'image/x-icon', rel => 'shortcut icon', href => "/favicon.ico";
            Link type => "text/css", rel => 'stylesheet', href => "/style/$style/style.css", media => "all";
            if ( $o{noindex} )
            {
                meta name => 'robots', content => 'noindex,nofollow,nosnippet,noodp,noarchive,noimageindex';end;
            }
        end 'head';
        
        body;
        
        my $topbar = $self->reqParam("topbar");
        if ($topbar && lc $topbar eq "true" ) 
        {
            # games, servers, search bar
            div class => 'nav';
                # search box
                form action => "/g", 'accept-charset' => 'UTF-8', method => 'get';
                    fieldset class => 'search';
                        p id => 'searchtabs';
                            a href => '/g', class => 'sel', 'Games';
                            a href => '/s', 'Servers';
                            input type => 'text', name => 'q', id => 'q', class => 'text', value => '';
                            input type => 'submit', class => 'submit', value => '', style => "display:none";
                        end;
                        a style => "font-size:x-small", href => "#", "advanced search";
                    end 'fieldset';
                end;
            end;
        }
        
            div id => "body";
            
                # start the page content with a header logo box
                div class => "titlebox";
                end;
                
                my $overrideStyle = $self->reqParam("style");
                if ($overrideStyle or $self->{style_box}) {
                # debug feature: force list of styles on floaty-box
                div class => "mainbox",
                    style => "position:absolute; left: 20px; top: 20px; width:200px";
                    
                    div class => "header";
                    h1 "Development";
                        p "This box allows for testing of multiple styles. Disable it from config.";
                    end;
                
                    ul style => "margin: 3px 20px 10pt 40px";
                        opendir(DIR, "$self->{root}/s/style") or die $!;
                        while (my $file = readdir(DIR)) 
                        {
                            next if ($file =~ m/^\./);
                            li;
                                a href => "?style=$file", $file;
                            end;
                        }
                        closedir(DIR);
                    end;
                end;
                }
}

################################################################################
# page footer
#   options: last_edited
################################################################################
sub htmlFooter 
{
    my ($self, %o) = @_;
    
                br style => "clear:both";
                
                div id => 'footer';
                    txt "$self->{site_name} | Powered by ";
                    a href => "http://333networks.com", "333networks";
                    txt " | ";
                    txt $o{last_edited} || "2021";
                end;
            end 'div'; # body
            script type => 'text/javascript', src => "/masterscript.js", '';
        end 'body';
    end 'html';
}

1;
