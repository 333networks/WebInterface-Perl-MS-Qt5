package MasterWebInterface::Handler::Json::JsonServerList;
use strict;
use TUWF ':html';
use Exporter 'import';
use JSON;

TUWF::register(
  qr{json/(.[\w]{1,20})}               => \&serverlist_json,
  qr{json/(.[\w]{1,20})/(all|[0a-z])}  => \&serverlist_json,
);

################################################################################
# LIST SERVERS
# Generate a list of selected games in the database per game (arg: gamename)
# Same as &serverlist, but with json output. 
################################################################################
sub serverlist_json 
{
    my($self, $gamename, $char) = @_;
    $gamename = "all" unless $gamename;
    
    # TODO DEPRECATE $char

    # sorting, page
    my $f = $self->formValidate(
        {
            get => 's',
            required => 0,
            default => 'gamename',
            enum => [ qw| hostname gamename country added gametype numplayers mapname | ] 
        },
        {
            get => 'o', 
            required => 0, 
            default => 'a', 
            enum => [ 'a','d' ] 
        },
        {
            get => 'p', 
            required => 0, 
            default => 1, 
            template => 'page',
        },
        {
            get => 'q', 
            required => 0, 
            default => '', 
            maxlength => 90 
        },
        { 
            get => 'r', 
            required => 0, 
            default => 100, 
            template => 'page' 
        },
        { 
            get => 'g', 
            required => 0, 
            default => '',  
            maxlength => 90 
        },
    );
    return $self->resNotFound if $f->{_err};
    
    # load server list from database
    my ( $list, $np, $p ) = $self->dbServerListGet(
        sort     => $f->{s}, 
        reverse  => $f->{o} eq 'd',
        gamename => $gamename,
        search   => $f->{q},
        page     => $f->{p},
        results  => $f->{r},
        updated  => $self->{window_time},
        gametype => $f->{g}, # TODO: implement in DB query
    );
    
    # get total number of players
    my $pl = 0;
    for (@{$list}) 
    {
        $pl += $_->{numplayers}
    }
    
    # return json data as the response
    my $json_data = encode_json [$list, {total => $p, players => $pl}];
    print { 
        $self->resFd() 
    } $json_data;

    # set content type and allow off-domain access (for example jQuery)
    $self->resHeader("Access-Control-Allow-Origin", "*");
    $self->resHeader("Content-Type", "application/json; charset=UTF-8");
}

1;
