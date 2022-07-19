package MasterWebInterface::Handler::Json::Motd;

use strict;
use utf8;
use JSON;
use TUWF ':html';
use Exporter 'import';
our @EXPORT = qw| motd_static |;

TUWF::register(
    qr{json/([\w]{1,20})/motd} => \&json_motd,
);

# Message of the Day for things like the JSON API or updateserver page
sub motd_static 
{
    my ($self, $gamedesc) = @_;
    return "<h1>$gamedesc</h1><p>Thank you for using the $self->{site_name} masterserver. For more information, visit <a href=\"$self->{site_url}\">$self->{site_url}</a>.</p>";
}

# MOTD for json api
sub json_motd
{
    my ($self, $gamename) = @_;
    
    # gamename defined
    my $gn_desc = $self->dbGetGameDesc($gamename) || $gamename;
    my $html = $self->motd_static($gn_desc);
    
    # get numServers
    my ($l,$x,$s) = $self->dbServerListGet(
        gamename => $gamename, 
        results  => 100,
    );
    
    my $p = 0;
    for (@{$l}) 
    {
        $p += $_->{numplayers}
    }
    
    # return json data as the response
    my $json_data = encode_json [{motd => $html}, {total => $s, players => $p}];
    print { $self->resFd() } $json_data;
    
    # set content type and allow off-domain access (for example jQuery)
    $self->resHeader("Access-Control-Allow-Origin", "*");
    $self->resHeader("Content-Type", "application/json; charset=UTF-8");
}

1;
