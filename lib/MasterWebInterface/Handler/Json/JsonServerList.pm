package MasterWebInterface::Handler::Json::JsonServerList;
use strict;
use TUWF ':html';
use Exporter 'import';
use JSON;

TUWF::register(
    qr{json/([\w]{1,20})} => \&serverlist_json,   # valid list 
);

#
# Generate a list of selected games in the database per game (arg: gamename)
#
sub serverlist_json 
{
    my($self, $gamename) = @_;
    $gamename = "all" unless $gamename;

    # sorting, page
    my $f = $self->formValidate(
        {   get => 's', required => 0, default => 'gamename', enum => [qw|hostname gamename country added gametype numplayers mapname|] },
        {   get => 'o', required => 0, default => 'a', enum      => ['a','d']    },
        {   get => 'p', required => 0, default => 1,   template  => 'page'   },
        {   get => 'r', required => 0, default => 50,  template  => 'page'   },
        {   get => 'q', required => 0, default => '',  maxlength => 90      },
        {   get => 'g', required => 0, default => '',  maxlength => 90      },
        {   get => 'a', required => 0, default => '',  maxlength => 200     },
        
        #{   get => 'gamename', required => 0, default => '',  maxlength => 90 }, # gamename in advanced search
        {   get => 'gametype', required => 0, default => '',  maxlength => 90 }, # gametype
        {   get => 'hostname', required => 0, default => '',  maxlength => 90 }, # hostname (replaces q in advanced search)
        {   get => 'mapname',  required => 0, default => '',  maxlength => 90 }, # mapname
        {   get => 'country',  required => 0, default => '',  maxlength => 90 }, # country (code)
    );
    
    # allow all outside sources to access the json api
    $self->resHeader("Access-Control-Allow-Origin", "*");
    
    # generate json error data if errors in field
    if ( $f->{_err} )
    {
        # response as json data
        $self->resJSON({
            error   => 1, 
            in      => "options", 
            options => $f->{_err}
        });
        return;
    }
    
    # load server list from database
    my ( $list, $np, $p ) = $self->dbServerListGet(
        sort     => $f->{s}, 
        reverse  => $f->{o} eq 'd',
        gamename => $gamename,
        search   => $f->{q},
        page     => $f->{p},
        results  => $f->{r},
        updated  => $self->{window_time},
        gametype => $f->{g},
        
        # parse extra request parameters for ubrowser.333networks.com
        ($f->{a} =~ m/popserv/ig) ? (popserv => 1) : (),
        ($f->{a} =~ m/utdemo/ig)  ? (utdemo  => 1) : (),
        
        gametype => $f->{gametype},
        hostname => $f->{hostname},
        mapname  => $f->{mapname},
        country  => $f->{country},  
    );
    
    # get total number of players in selected page(s)
    my $pl = 0;
    for (@{$list}) 
    {
        $pl += $_->{numplayers};
        s/</&lt;/g for values %{$_};
        s/>/&gt;/g for values %{$_};
    }
    
    # response as json data
    $self->resJSON([
        $list, 
        {total => $p, players => $pl}
    ]);
}

1;
