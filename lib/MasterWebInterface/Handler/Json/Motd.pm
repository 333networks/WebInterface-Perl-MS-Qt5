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
        updated  => $self->{window_time},
        limit => 9999,
        sort     => "numplayers", 
        reverse  => 1,
    );
    
    my $p = 0;
    for (@{$l}) 
    {
        $p += $_->{numplayers};
        last unless $_->{numplayers}
    }
    
    # response as json data
    $self->resHeader("Access-Control-Allow-Origin", "*");
    $self->resJSON([
        {motd => $html}, 
        {total => $s, players => $p}
    ]);

}

1;
