## Web Interface for MasterServer-Qt5
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
    * TUWF (http://dev.yorhel.nl/tuwf)

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
  db_login  => ["dbi:SQLite:dbname=/server/masterserver/qt5/data/masterserver.db",'',''],
```

When more than one website style exists, it can be selected in the following option. If no additional style files are (manually) installed, do not alter this option.
```
  # display
  style     => "classic2",
```

By default, only servers that have updated in the last half hour are shown. To show servers for a shorter or longer period of time after the last update increase or decrease the value of the option `window_time`. This value is provided in seconds (3600 seconds is 1 hour).
```
  # do not display servers older than [seconds]
  window_time => 1800,
```

## Apache settings
```
LoadModule rewrite_module modules/mod_rewrite.so
AddHandler cgi-script .cgi .pl
```

Update the vhost configuration for the Web Interface to match your repository folder path:

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
