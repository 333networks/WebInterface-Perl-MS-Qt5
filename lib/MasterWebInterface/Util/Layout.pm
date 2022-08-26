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
    
    html lang => "en";
        head;
            title "$o{title} :: $self->{site_name} masterserver";
            Link type => 'image/x-icon', rel => 'shortcut icon', href => "/favicon.ico";
            Link type => "text/css", rel => 'stylesheet', href => "/style/$self->{style}/style.css", media => "all";
            if ( $o{noindex} )
            {
                meta name => 'robots', content => 'noindex,nofollow,nosnippet,noodp,noarchive,noimageindex';end;
            }
        end 'head';
        
        body;
            div id => "body";
            
                # start the page content with a header logo box
                div class => "titlebox";
                end;
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
                    txt $o{last_edited} || "2022";
                end;
            end 'div'; # body
            script type => 'text/javascript', src => "/masterscript.js", '';
        end 'body';
    end 'html';
}

1;
