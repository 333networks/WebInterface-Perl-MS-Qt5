package MasterWebInterface::Handler::Json::ApiDoc;
use strict;
use TUWF ':html';
use Exporter 'import';
use JSON;

TUWF::register(
  qr{json} => \&json_docs,
);

################################################################################
# Json Documentation
# Documentation about the Json API
################################################################################
sub json_docs 
{
    my $self = shift;
    $self->htmlHeader(title => "Json API");
    $self->htmlSearchBox(title => "Servers", action => "/s", sel => 'j', fq => '');
    
    div class => "mainbox apidoc";
        div class => "header";
            h1 "Json API";
            p "333networks has a Json API. With this API, it is possible to obtain server lists and specific server information for your own banners, ubrowser or other application.";
        end;
        
        #
        # ToS
        #
        
        h2 "Permission & Terms of Use";
        p;
            txt "The following permissions and conditions are in effect for making use of the Json API: ";
        end;
        
        p "You are allowed to access our API with any application and/or script, self-made or not, to obtain our server lists and server information on the condition that somewhere, anywhere in your application or script you mention that the information is obtained from 333networks.";
        
        p "You are not allowed to flood the API with requests or query our API continuously or with a short interval. If you draw too much network traffic from 333networks, we consider this flooding and will terminate your ability to query our API. Server information is updated every 15 minutes, there is no point in requesting information at a faster rate as there will be no new information available.";
        
        p "Intended use: use the serverlist request to get show a list of all servers. After loading the list, your visitors/users can select a single server to display detailed information. Do NOT use the serverlist to immediately show detailed information for ALL servers, this causes a ludicrous amount of information requests and will get you excluded from our API. Not sure whether you are doing it right? Contact us!";
        
        #
        # use
        #
        h2 "Use";
        p "The Json API consists of three functions to query for information. The methods occur over HTTP and are presented as Json data. The first function requests the \"Message of the Day\", often used to make announcements about the game. The second method returns a list of servers and can be manipulated by gamename. The third method returns detailed server information for an individual server.";
        
        
        h2 "Message of the Day";
        p;
            txt "It is possible to pull announcements from the 333networks Json API with the ";
            span class => "code", "motd";
            txt " command. This command returns an html string with the current 333networks announcements for the selected ";
            span class => "code", "gamename";
            txt ". This string is suitable for direct JQuery's ";
            span class => "code", ".html()";
            txt " function. Additionally, it contains the amount of servers and players as described for the serverlist. This method can be used to announce service messages.";
        end;
        
        div class => "code";
            txt "$self->{site_url}/json/(.[\\w]{1,20})/motd";
        end;
        
        
        h2 "Serverlist";
        p "With the API you can pull a serverlist directly from the masterserver. The API applies the following regex to process your request:";
        div class => "code";
            txt "$self->{site_url}/json/(.[\\w]{1,20})";
        end;
        p;
            txt "In this regex, ";
            span class => "code", "(.[\\w]{1,20})";
            txt " refers to the ";
            span class => "ext", "gamename";
            txt ". This is the abbreviation that every game specifies in their masterserver protocol. A comprehensive list of gamenames is found on the ";
            a href => "/g/all", "games";
            txt " page by looking at the last part of the URL.";
        end;
        
        p;
            txt "It is also possible to provide ";
            span class => "code", "GET";
            txt " information in the url. Allowed options are:";
        end;
        
        ul;
            li; 
                span class => "code", "s"; 
                txt " - sort by country, hostname, gametype, ip, hostport, numplayers and mapname.";
            end;
            li; 
                span class => "code", "o"; 
                txt " - sorting order: 'a' for ascending and 'd' for descending."; 
            end;
            li; 
                span class => "code", "r"; 
                txt " - number of results. Defaults to 50 if not specified. Minimum 1, maximum 1000."; 
            end;
            li; 
                span class => "code", "p"; 
                txt " - page. Show the specified page with results. Total number of entries is included in the result."; 
            end;
            li; 
                span class => "code", "q"; 
                txt " - search query. Identical to the search query on the "; 
                a href => "/s", "servers"; 
                txt " page. Maximum query length is 90 characters."; 
            end;
        end;
        
        #
        # list request format
        #
        
        h2 "Serverlist request examples:";
        p;
            txt "The following examples have different outcomes. In the first example, we request a serverlist of ";
            span class => "code", "all";
            txt " servers, regardless of type and/or name. The second example requests only servers of the game ";
            span class => "code", "Unreal"; 
            txt ". In the last example, we request a serverlist with the gamename ";
            span class => "code", "333networks";
            txt ", with only ";
            span class => "code", "2";
            txt " results per page, page ";
            span class => "code", "1";
            txt " and with the search word ";
            span class => "code", "master";
            txt ".";
        end;
        
        div class => "code";
            txt "$self->{site_url}/json/";
            span class => "ext", "all";
            br;
            txt "$self->{site_url}/json/";
            span class => "ext", "unreal";
            br;
            txt "$self->{site_url}/json/";
            span class => "ext", "333networks";
            txt "?r=";
            span class => "ext", "2";
            txt "&p=";
            span class => "ext", "1";
            txt "&q=";
            span class => "ext", "master";
        end;
        
        h2 "Serverlist result examples:";
        p "The API returns Json data in the following format, using the third request as an example. This is example data and may vary from what you receive when performing the same query.";
        
        div class => "code";
            pre json_result_1();
        end;
        
        p;
            txt "The result contains an array of server entries and the ";
            span class => "code", "total";
            txt " amount of entries. In this case, that is ";
            span class => "code", "2";
            txt " entries listed and ";
            span class => "code", "5"; 
            txt " total entries, implying that there is one more server not shown or on a next page. With the specified number of results specified by the user and the total amount of servers provided by the API, you can calculate how many pages there are to be specified. If applicable, it also shows the current number of ";
            span class => "code", "players"; 
            txt " that are currently in the selected servers. Every server entry has a number of unsorted keywords. Timestamps are linux epoch, in UTC.";
        end;
        
        p "The available keywords that are returned by the API are: ";
        div class => "code", join (" ", qw| id ip hostport hostname gamename label country numplayers maxplayers maptitle mapname gametype dt_added dt_updated|);

        p "There are more keywords available for individual servers. Detailed information about a server is obtained with the individual request as described below. Keywords of both requests are described in the tables below. ";

        
        h2 "Server details";
        p "Your application or script can also request detailed information for a single server. This is done in a similar way as requesting a server list. The following general regex is used by 333networks:";
        
        div class => "code";
            txt  "$self->{site_url}/json/(.[\\w]{1,20})/([\\:\\.\\w]{9,35})";
        end;
        
        p;
            txt "This restricts requests to the correct url with a gamename ";
            span class => "code", "(.[\\w]{1,20})";
            txt " and an IP:port ";
            span class => "code", "([\\:\\.\\w]{9,35})";
            txt " for IPv4 and IPv6 addresses and numerical port number. There are no additional query options or GET options. It is possible that the gamename specified does not match the ";
            txt "gamename";
            txt " as stored in our database. The result will include the correct gamename that was specified in our database.";
        end;
        
        p "The following example requests detailed information by IP address and hostport.";
        
        #
        # individual server details request format
        #
        
        h3 "Server details request:";
        div class => "code";
            txt "$self->{site_url}/json/";
            span class => "ext", "333networks";
            txt "/";
            span class => "ext", "84.83.176.234";
            txt ":";
            span class => "ext", "28900";
        end;
        
        h3 "Server details result:";
        p "The API returns Json data in the following format, using the requests above as an example. This is example data and may vary from what you receive when performing the same query.";
        
        div class => "code";
            # snippet 1, below
            pre json_result_2();
        end;
        
        p "The result has a single entry of parameters with a number of unsorted keywords. The available keywords are in addition to the keywords are specified in multiple tables below.";
        
        p;
            txt "The player object ";
            span class => "code", "player_n";
            txt " represent the players in the server. This is a Json object as part of the larger object above. The available keywords are specified in the table below.";
        end;
        
        h2 "Keyword reference";
        p "Values, type and descriptions of fields that are returned by the Json API:";
        
        # generate reference tables
        json_database_ref();
        
        h2 "Feedback";
        p;
            txt "We wrote the Json API with the intention to make the 333networks masterserver data as accessible as possible. If you feel like any functionality is missing or incorrectly shared, do not hesitate to contact us to provide feedback. Additionally, we request that you follow the advise on usage as we described under the Terms of Use on top of this page, so we can keep providing this API.";
        end;

    end; # mainbox
    $self->htmlFooter(last_change => "May 2021");
}

# list of value / type / descriptions directly from database
sub json_database_ref
{
    my @keyval = (
    { title => "Server identifier information",
      table => [
        ["id",          "int",  "gameserver ID in list database"],
        ["sid",         "int",  "reference ID for detailed information"],
        ["ip",          "text", "server IP address (in IPv6 format)"],
        ["queryport",   "int",  "UDP status query port"],
        ["hostport",    "int",  "hostport to join the server"],
        ["hostname",    "text", "name of the specific server"],
        ["country",     "text", "2-letter country code where the server is hosted"],
        ["location",    "text", "GameSpy regional indication (continent index or 0 for world)"],
        ],
    },
    { title => "Server flags \& datetime",
      table => [
        ["f_protocol",          "int",  "protocol index to distinguish between GameSpy v0 and others"],
        ["f_blacklist",         "int",  "server blacklisted?"],
        ["f_auth",              "int",  "authenticated response to the secure/validate challenge?"],
        ["f_direct",            "int",  "direct beacon to the masterserver?"],
        ["dt_added",            "long", "UTC epoch time that the server was added"],
        ["dt_beacon",           "long", "UTC epoch time that the server sent a heartbeat"],
        ["dt_sync",             "long", "UTC epoch time that the server was last synced from another masterserver"],
        ["dt_updated",          "long", "UTC epoch time that the server information was updated"],
        ["dt_serverinfo",       "long", "UTC epoch time that the detailed server information was updated"],
        ],
    },
    { title => "Gamedata",
      table => [
        # gamedata
        ["gamename",    "text", "gamename of the server"],
        ["label",       "text", "comprehensible game title associated with gamename"],
        ["gamever",     "text", "game version of the server"],
        ["minnetver",   "text", "minimal required game version to join"],
        ],
    },
    { title => "Game settings (detailed information)",
      table => [
        ["listenserver",        "text", "dedicated server indication"],
        ["adminname",           "text", "server administrator's name"],
        ["adminemail",          "text", "server administrator's contact information"],
        ["password",            "text", "passworded or non-public server"],
        ["gametype",            "text", "type of game: capture the flag, deathmatch, assault and more"],
        ["gamestyle",           "text", "in-game playing style"],
        ["changelevels",        "text", "automatically change levels after match end"],
        ["mapurl",              "text", "direct url of the map thumbnail relative from this site's domain"],
        ["mapname",             "text", "filename of current map"],
        ["maptitle",            "text", "title or description of current map"],
        ["minplayers",          "int", "minimum number of players to start the game"],
        ["numplayers",          "int", "current number of players"],
        ["maxplayers",          "int", "maximum number of players simultaneously allowed on the server"],
        ["botskill",            "text", "skill level of bots"],
        ["balanceteams",        "text", "team balancing on join"],
        ["playersbalanceteams", "text", "players can toggle automatic team balancing"],
        ["friendlyfire",        "text", "friendly fire rate"],
        ["maxteams",            "text", "maximum number of teams"],
        ["timelimit",           "text", "time limit per match"],
        ["goalteamscore",       "text", "score limit per match"],
        ["fraglimit",           "text", "score limit per deathmatch"],
        ["mutators",            "text", "comma-separated mutator/mod list"],
        ["misc",                "text", "miscellaneous server attributes (reserved)"],
        ["player_#",            "text", "player information as Json object for player #, see table below"],
        ],
    },
    { title => "Player information",
      table => [
        ["sid",         "int",  "associated server ID (per player)"],
        ["name",        "text", "player display name"],
        ["team",        "text", "player indication as team number, color code or text string"],
        ["frags",       "int",  "number of frags or points"],
        ["mesh",        "text", "player model / mesh"],
        ["skin",        "text", "player body texture"],
        ["face",        "text", "player facial texture"],
        ["ping",        "int",  "player ping"],
        ["misc",        "text", "miscellaneous player attributes (reserved)"],
        ["dt_player",   "long", "UTC epoch time that the player information was updated"],
        ],
    },
    ); 
    
    
    use Data::Dumper 'Dumper';
    
    for my $keytype (@keyval)
    {
        h3 $keytype->{title};
        table class => "keyval";
            Tr;
                th class => "tc1", "Value";
                th class => "tc2", "Type";
                th "Description";
            end;
            
            for my $r (@{$keytype->{table}})
            {
                my @tr = @{$r};
                Tr;
                    td class => "tc1";
                        span class => "code", $tr[0]; 
                    end;
                    td class => "tc2", $tr[1]; 
                    td $tr[2];
                end;
            }
        end;
    }
}

# json output for example 1
sub json_result_1
{
    return '[
    [
        {
            "id":1990,
            "ip":"::ffff:84.83.176.234"                    
            "hostport":28900,
            "hostname":"master.333networks.com (333networks MasterServer)",
            "gamename":"333networks",
            "gametype":"MasterServer",
            "label":"333networks Masterserver",
            "country":"NL",
            "numplayers":15,
            "maxplayers":2966,
            "maptitle":null,
            "mapname":"333networks",
            "dt_added":1616895602,
            "dt_updated":1621019250,            
        },
        {
            "id":1117,        
            "ip":"::ffff:162.154.33.129",
            "hostport":28900
            "hostname":"master.gonespy.com",
            "gamename":"333networks",
            "gametype":"Masterserver",
            "label":"333networks Masterserver",
            "country":"US",
            "numplayers":5,
            "maxplayers":847,
            "maptitle":"",
            "mapname":"333networks",
            "dt_added":1616593343,
            "dt_updated":1621019247,
        }
    ],
    {
        "players":20,
        "total":5
    }
]';
}

sub json_result_2
{
    return '{
        "id":3,
        "ip":"::ffff:45.74.100.250",
        "hostport":10205,
        "mapname":"DXMP_iceworld2",
        "adminname":"Canna the visionary l Disciple Derp191 and RoninMastaFX",
        "hostname":"~Canna\'s Buddhist Server~",
        "mapurl":"/map/default/333networks.jpg",
        "gamever":"1100",
        "gametype":"CDX BDM",
        "gamename":"deusex",
        "country":"CA",
        "dt_updated":1621022768,      
        "player_0":
            {
                "sid":3,
                "name":"Dark191",                            
                "team":"0",            
                "frags":8,
                "mesh":"cmJCDenton",
                "skin":"None",
                "face":""
                "ping":63,
                "dt_player":1621022768,
                "misc":"",
            },
        "player_1":
            {
                "sid":3,
                "name":"Anya",                            
                "team":"0",            
                "frags":12,
                "mesh":"cmJCDenton",
                "skin":"None",
                "face":""
                "ping":54,
                "dt_player":1621022768,
                "misc":"",
            },
        }';
}

1;
