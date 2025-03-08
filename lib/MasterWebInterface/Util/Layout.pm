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
            
            # metadata for previews
            meta property => "theme-color",    content => ($self->{meta_color} // "#111111");
            meta property => "og:type",        content => "website";
            meta property => "og:site_name",   content => $self->{site_name};
            meta property => "og:title",       content => substr($o{title},0,50);
            meta property => "og:description", content => ($o{meta_desc} // "");
            meta property => "og:image",       content => ($o{meta_img } // "/map/default/333networks.jpg");
            
            if ( $o{noindex} )
            {
                meta name => 'robots', content => 'noindex,nofollow,nosnippet,noodp,noarchive,noimageindex';
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
