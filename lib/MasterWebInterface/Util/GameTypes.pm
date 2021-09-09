package MasterWebInterface::Util::GameTypes;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT = qw| better_gametype |;

# translate default gametype names to better readable equivalents
# in: string, out: string
sub better_gametype
{
    my ($s, $gametype) = @_;
    
    return " " unless $gametype;
    
    # all available equivalents
    my %types = (
        
        # general abbreviations
        "DM"    => "Deathmatch",
        "CTF"   => "Capture the Flag",
        "COOP"  => "Cooperative Mission",
        
            
        # Rune
        "ArenaGameInfo"     => "Arena",
        "RuneMultiPlayer"   => "Deathmatch",
        "TVGame"            => "Thirsty Vikings",
        "SRGame"            => "Shadow Rules",
        "NomadsGame"        => "Nomads",
        "CapTheTorchGame"   => "Capture the Torch",
        "HeadBallGame"      => "Headball",
        "SarkballGame"      => "Sarkball",
        "VasArenaGame"      => "VAS Arena",

        # Unreal and Unreal Tournament
        "DeathMatchPlus"        => "Deathmatch",
        "TeamGamePlus"          => "Team Deathmatch",
        "EUTDeathMatchPlus"     => "Extra UT Deathmatch",
        "CTFGame"               => "Capture the Flag",
        "Domination"            => "Domination",
        "LastManStanding"       => "Last Man Standing",
        "TLastManStanding"      => "Team Last Man Standing",
        "InstaGibDeathMatch"    => "InstaGib",
        "Assault"               => "Assault",
        "MonsterHunt"           => "Monsterhunt",
        "BunnyTrackGame"        => "Bunnytrack",
        "BunnyTrackNewNet"      => "Bunnytrack",
        "JailBreak"             => "Jailbreak",
        "TO3"                   => "Tactical Ops",
        "LeagueAssault"         => "League Assault",
        "s_SWATGame"            => "S.W.A.T.",
        "SiegeGI"               => "Siege",
        "FreeSiegeGI"           => "Siege",
    );
    
    return ($types{$gametype} // $gametype);
}

1;
