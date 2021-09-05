# Web Interface for MasterServer-Qt5
Web interface in Perl for MasterServer-Qt5.

## DESCRIPTION
This repository contains software for a web interface to display information obtained by the 333networks MasterServer for the support of various legacy games. 

## AUTHOR
* Darkelarious
* darkelarious@333networks.com

## REQUIREMENTS
* MasterServer-Qt5 (code.333networks.com)
* Apache/httpd
* Perl 5.10 or above
* The following CPAN modules:
    * DBI
    * DBD::SQLite
    * TUWF
    * Image::Size (optional for style generation)

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

Configure the path to the database that the masterserver uses. The location of this database is found in the documentation of `MasterServer-Qt5`.
```
  # database connection
  db_login => ["dbi:SQLite:dbname=/path/to/your/data/masterserver.db",'',''],
```

When more than one website style exists, it can be selected in the following option. If no additional style files are (manually) installed, do not alter this option.
```
  # display
  style => "333networks",
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
```

Some parameters can be colors, textures or both. Fields with the (texture) indication can be both images and colors, such as `#0af`, `#0af box.png`, `box.png`, but (color) implies color ONLY.  

To compile a skin, run the command `./skingen.pl SKINNAME` from the `util` directory, where skinname is the lowercase folder name of your skin. The generated stylesheet can now be used in your webinterface config file under the `style => skinname` option.

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
* No additional styling available for third parties. Will come when the rest of the website is stable.
* Country name/flag is always "Earth". There is a third party script that updates these in the database, which may or may not be released in the future.

## COPYING
See COPYING file
