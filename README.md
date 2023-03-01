# Web Interface for MasterServer-Qt5
Web interface in Perl for MasterServer-Qt5.

## DESCRIPTION
This repository contains software for a web interface to display information obtained by the 333networks MasterServer for the support of various legacy Gamespy games. 

## AUTHOR
* Darkelarious
* darkelarious@333networks.com

## REQUIREMENTS
* MasterServer-Qt5 (code.333networks.com)
* Apache/httpd
* Perl 5.10 or above
* The following CPAN modules:
    * `DBI`
    * `DBD::SQLite`
    * `TUWF`
    * `JSON`
    * `Image::Size` (optional for style generation)
    * `AnyEvent` (optional for IP to Country lookup)
    * `LWP::Simple` (optional for IP to Country lookup)

## INSTALL
This repository consists of Perl modules and is run by a http deamon. First, the MasterServer-Qt5 repository should be installed and configured in order to run this web interface. This web interface requires access to the database generated and updated by MasterServer-Qt5.

## CONFIGURATION
The 333networks masterserver interface comes with options. These options are found in configuration file `data/settings.pl`. First provide the site name and URL. These are used for the title bar and links.
```
  # site (for sharing options)
  site_url  => "http://master.333networks.com",
  site_name => "333networks",
  email     => 'master@333networks.com',
```

Configure the path to the database that the masterserver uses. The location of this database is found in the documentation of `MasterServer-Qt5`. Depending on your configuration, you may have to apply user permissions with `chmod 644 masterserver.db` before the website can interact with it.
```
  # database connection
  db_login => ["dbi:SQLite:dbname=/path/to/your/data/masterserver.db",'',''],
```

When more than one website style exists, it can be selected in the following option. If no additional style files are (manually) installed, do not alter this option.
```
  # display
  style => "333networks",
```

It is possible to automatically apply styles for April's Fools, Halloween and Christmas. This is enabled with the following option, which is disabled by default. When style folders do not exist for these events, the default style remains active.
```
  # rotate styles
  rotate_styles => 1,
```

By default, only servers that have updated in the last half hour are shown. To show servers for a shorter or longer period of time after the last update increase or decrease the value of the option `window_time`. This value is provided in seconds (3600 seconds is 1 hour).
```
  # do not display servers older than [seconds]
  window_time => 1800,
```

## Style generation
It is possible to generate a website with your preferred colours, background textures and personal logo. To build a new style, create a folder and conf file at `s/style/SKINNAME/conf`. Fill in the following parameters:
```
// name   example         description
//------------------------------------------------------------------------------
name      stylename       description of the style/name of the style
author    Darkelarious    style author (commented in style.css for credits)

// backgrounds
bodybg    #222 body.gif   body background (texture)
boxbg1    #333            box background (texture)
boxbg2    #111            menu backgrounds, buttons, thumbnail/image boxes (texture)
boxbg3    #222            odd row accents (texture)
shadow    #222            shadow color (color)

// text
textcol1  #ccc            main text color
textcol2  #0af            primary color for borders, links (color)
textcol3  #ff0            secondary color for link:hover, actions (color)
textcol4  #666            accent color for complementing main text color (color)

// logos
bglogo    333networks.png logo in background (recommended 75 px high max)

// symbol filter
pngfilter sepia(56%)      css filter property to match status symbols with text colors
```

Some parameters can be colors, textures or both. Fields with the (texture) indication can be both images and colors, such as `#0af`, `#0af box.png`, `box.png`, but (color) implies color ONLY. The CSS `filter` property to match the status symbols can be automatically calculated on <https://codepen.io/sosuke/pen/Pjoqqp>.  

To compile a skin, run the command `./skingen.pl SKINNAME` from the `util` directory, where skinname is the lowercase folder name of your skin. The generated stylesheet can now be used in your webinterface config file under the `style => skinname` option. Stylesheets may be edited manually, but running the command again will overwrite previous changes without confirmation.

## Optional: IP to Country lookup
The masterserver does not perform an IP to Country lookup. The `listcountry.pl` Perl script queries an IP every 10 seconds through the <ip-api.com> public Json API and inserts successful queries in the masterserver database.

## Apache settings
Update the vhost configuration for the Web Interface to match your repository folder path. You may be required to enable modules such as `mod_rewrite` and `fcgi`.

```
#
# Master Web Interface
#
<VirtualHost *:80>
ServerAdmin master@yourdomain.com
ServerName  master.yourdomain.com

DocumentRoot "/path/to/WebInterface-Perl-MS-Qt5/s"
AddHandler cgi-script .pl

RewriteEngine On
RewriteCond "%{DOCUMENT_ROOT}/%{REQUEST_URI}" !-s
RewriteRule ^/ /masterinterface.pl

ErrorLog  /path/to/WebInterface-Perl-MS-Qt5/log/Error.log
CustomLog /path/to/WebInterface-Perl-MS-Qt5/log/Access.log combined

<Directory "/path/to/WebInterface-Perl-MS-Qt5/s">
    Options +FollowSymLinks +ExecCGI
    AllowOverride None
    Require all granted
</Directory>
</VirtualHost>
```

## KNOWN ISSUES
There are a few known issues that will be resolved in future versions. The following issues are listed and do not need to be reported.
* no issues tracked!

## COPYING
See COPYING file
