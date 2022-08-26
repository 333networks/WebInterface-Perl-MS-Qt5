package MasterWebInterface::Handler::ErrorPages;
use strict;
use TUWF ':html';

# handle 404 and 500
TUWF::set(
    error_404_handler => \&handle404,
    error_500_handler => \&handle500,
);

TUWF::register(
    qr{500} => sub {die "Process died on purpose, but with a lot of text to test if the whole error is correctly displayed on the screen when debug information is enabled in the website configuration. "},
);

#
# 404 page or json status
sub handle404 
{
    my $self = shift;

    # json error status separately
    if ( $self->reqPath() =~ m/^\/json/ig)
    {
        # response as json data
        $self->resHeader("Access-Control-Allow-Origin", "*");
        $self->resJSON({
            error => 1, 
            in => "url_format"
        });
        return;
    }
    
    $self->resStatus(404);
    $self->htmlHeader(title => '404 - Not Found');
    $self->htmlFilterBox(title => "Servers", action => "/s", sel => 's', fq => '');
    
    div class => "mainbox warning";
        div class => "header";
            h1 'Page not found';
            p "Error 404: the page could not be found.";
        end;
        
        div class => "description";
            p;
                txt 'It seems the page you were looking for does not exist,';
                br;
                txt 'perhaps our search function may yield results?';
            end;
        end;
    end;
    $self->htmlFooter;
}

#
# 500 page or json status
sub handle500 
{
    my($self, $error) = @_;
    
    # json error status separately
    if ( $self->reqPath() =~ m/^\/json/ig)
    {
        # response as json data
        $self->resHeader("Access-Control-Allow-Origin", "*");
        $self->resJSON({
            error => 1, 
            in => "internal_error", 
            internal => ( $self->debug ? $error : () )
        });
        return;
    }
    
    $self->resStatus(500);
    $self->htmlHeader(title => '500 - Internal Server Error');
    $self->htmlFilterBox(title => "Servers", action => "/s", sel => 's', fq => '');
    
    div class => "mainbox warning";
        div class => "header";
            h1 'Internal Server Error';
            p "Error 500: loading this page caused an internal error.";
        end;
        
        div class => "description";
            p;
                txt 'Something went wrong on our side. The problem was logged ';
                br;
                txt 'and will be fixed shortly. Please try again later.';
            end;
        
            if ($self->debug) 
            {
                p $error;
            }
        end;
    end;
    $self->htmlFooter;
}

1;
