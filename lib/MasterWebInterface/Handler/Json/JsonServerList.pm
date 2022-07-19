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
        {   get => 'r', required => 0, default => 100, template  => 'page'   },
        {   get => 'q', required => 0, default => '',  maxlength => 90      },
        {   get => 'g', required => 0, default => '',  maxlength => 90      },
        {   get => 'a', required => 0, default => '',  maxlength => 200     },
    );
    
    # generate json error data if errors in field
    if ( $f->{_err} )
    {
        $self->resHeader("Content-Type", "application/json; charset=UTF-8");
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
    );
    
    # get total number of players
    my $pl = 0;
    for (@{$list}) 
    {
        $pl += $_->{numplayers}
    }
    
    # return json data as the response
    $self->resHeader("Content-Type", "application/json; charset=UTF-8");
    $self->resJSON( [$list, {total => $p, players => $pl}] );
}

1;
