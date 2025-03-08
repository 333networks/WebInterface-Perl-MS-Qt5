package MasterWebInterface::Handler::Json::JsonServerInfo;
use strict;
use TUWF ':html';
use Exporter 'import';
use Socket;
use JSON;

TUWF::register(
    qr{json/([\w]{1,20})/(\w{4}:\w{4}:\w{4}:\w{4}:\w{4}:\w{4}:\w{4}:\w{4}):(\d{1,5})} => \&json_serverinfo, # ipv6
    qr{json/([\w]{1,20})/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}):(\d{1,5})}              => \&json_serverinfo, # ipv4
    qr{json/([\w]{1,20})/([\w\.]{3,63}):(\d{1,5})}                                    => \&json_serverinfo, #domain name

);

#
# Show server info for an individual server.
# 
sub json_serverinfo 
{
    my ($self, $gamename, $addr, $port) = @_;
    
    # domain name check
    my $ip = $addr;
    if ($addr =~ m/[a-z]/ig )
    {
        # $addr holds a value that is a domain. try to resolve.
        my $packed_ip = gethostbyname($ip);
        $ip = inet_ntoa($packed_ip) if (defined $packed_ip);
    }

    # select server from database
    my $info = $self->dbGetServerInfo(
        ip => $ip,
        hostport => $port,
        limit => 1,
    )->[0];
    
    # allow all outside sources to access the json api
    $self->resHeader("Access-Control-Allow-Origin", "*");
    
    # return error state on invalid IP/port
    unless ($info)
    {
        # response as json data
        $self->resJSON({
            error => 1,
            in    => "not_in_db",
            ip    => $ip // "0.0.0.0", 
            port  => $port // 0, 
        });
        return;
    }

    # load player data if available
    my %players = ();
    my $pl_list = $self->dbGetPlayerInfoList(sid => $info->{id});
    
    for (my $i=0; defined $pl_list->[$i]->{name}; $i++) 
    {
        
        # fix html "injection" (quick fix, ask Yorhel for better suited solution)
        s/</&lt;/g for values %{$pl_list->[$i]};
        s/>/&gt;/g for values %{$pl_list->[$i]};
    
        $players{"player_$i"} = $pl_list->[$i];
    }
    
    # merge with rest of info
    $info = { %$info, %players  } if %players;

    # find the correct thumbnail, otherwise game default, otherwise 333 default
    my $mapname = lc $info->{mapname};
    
    # FIXME
    $info->{debug_map_path} = "$self->{root}/s/map/$info->{gamename}/$mapname.jpg";

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
    
    # fix html "injection" (quick fix, ask Yorhel for better suited solution)
    s/</&lt;/g for values %{$info};
    s/>/&gt;/g for values %{$info};

    # response as json data
    $self->resJSON($info);
}

1;
