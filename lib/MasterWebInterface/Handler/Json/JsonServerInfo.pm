package MasterWebInterface::Handler::Json::JsonServerInfo;
use strict;
use TUWF ':html';
use Exporter 'import';
use JSON;

TUWF::register(
    qr{json/(.[\w]{1,20})/([\:\.\w]{9,35})} => \&json_serverinfo,
);

################################################################################
# Server Info
# Show server info for an individual server
# Same as &server_info, but with json output. 
# returns "error:1" if errors occurred
################################################################################
sub json_serverinfo 
{
    my ($self, $gamename, $s_addr, $s_port) = @_;

    # parse from ipv4/6 and soft sanity check
    my ($ip, $port) = $self->from_addr_str($s_addr);

    # select server from database
    my $info = $self->dbGetServerInfo(
        ip => $ip,
        hostport => $port,
        limit => 1,
    )->[0] if ($ip && $port);

    # display an error in case of an invalid IP or port
    unless ($info)
    {
        my %err = (error => 1, ip => $ip, port => $port);
        my $e = \%err;
        my $json_data = encode_json $e;
        my $json_data_size = keys %$e;

        # return json data as the response
        print { $self->resFd() } $json_data;

        # set content type at the end
        $self->resHeader("Access-Control-Allow-Origin", "*");
        $self->resHeader("Content-Type", "application/json; charset=UTF-8");
        return;
    }

    # load player data if available
    my %players = ();
    my $pl_list = $self->dbGetPlayerInfoList(sid => $info->{id});
    
    for (my $i=0; defined $pl_list->[$i]->{name}; $i++) 
    {
        $players{"player_$i"} = $pl_list->[$i];
    }
    
    use Data::Dumper 'Dumper';
    my $str = Dumper $pl_list;
    
    # merge 
    #$info = { %$info, %$details } if $details;
    $info = { %$info, %players  } if %players;


    # find the correct thumbnail, otherwise game default, otherwise 333 default
    my $mapname = lc $info->{mapname};

    # if map figure exists, use it
    if (-e "$self->{root}/s/map/$info->{gamename}/$mapname.jpg") 
    {
        # map image
        $info->{mapurl} = "/map/$info->{gamename}/$mapname.jpg";
    }
    # if not, game default image
    elsif (-e "$self->{root}/s/map/default/$info->{gamename}.jpg") 
    {
        # game image
        $info->{mapurl} = "/map/default/$info->{gamename}.jpg";
    }
    # otherwise 333networks default
    else
    {
        # 333networks default
        $info->{mapurl} = "/map/default/333networks.jpg";
    }
    
    # encode
    my $json_data = encode_json $info;
    my $json_data_size = keys %$info;

    # return json data as the response
    print { $self->resFd() } $json_data;

    # set content type and allow off-domain access (for example jQuery)
    $self->resHeader("Access-Control-Allow-Origin", "*");
    $self->resHeader("Content-Type", "application/json; charset=UTF-8");
}

1;
