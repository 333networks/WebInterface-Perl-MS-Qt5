FROM debian:bullseye-slim

RUN apt-get update \
    && apt-get install -y apache2 perl build-essential \
      libdbi-perl \
      libdbd-sqlite3-perl \
      libjson-perl \
      libimage-size-perl \
      libanyevent-perl \
      libio-all-lwp-perl \
      libfcgi-perl \
      libgeography-countries-perl \
      libapache2-mod-fcgid \
    && cpan TUWF \
    && cpan "LWP::Simple" \
    && apt-get autoclean

RUN a2enmod rewrite fcgid proxy_fcgi cgi

COPY . /masterserver

# Create Apache VirtualHost configuration on custom listen port
RUN echo 'Listen 8080\n\
    <VirtualHost *:8080>\n\
    DocumentRoot "/masterserver/s"\n\
    AddHandler cgi-script .pl\n\
    \
    RewriteEngine On\n\
    RewriteCond "%{DOCUMENT_ROOT}/%{REQUEST_URI}" !-s\n\
    RewriteRule ^/ /masterinterface.pl\n\
    \
    ErrorLog  /masterserver/log/error.log\n\
    CustomLog /masterserver/log/access.log combined\n\
    \
    <Directory "/masterserver/s">\n\
        Options +FollowSymLinks +ExecCGI\n\
        AllowOverride None\n\
        Require all granted\n\
    </Directory>\n\
    </VirtualHost>' > /etc/apache2/sites-available/000-default.conf \
    && echo "" > /etc/apache2/ports.conf

# Create FastFGI configuration which works with our stand-alone Apache instance
RUN echo '<IfModule mod_fcgid.c>\n\
    FcgidIPCDir                /run/mod_fcgid\n\
    FcgidProcessTableFile      /run/mod_fcgid/fcgid_shm\n\
    FcgidMinProcessesPerClass  0\n\
    FcgidMaxProcessesPerClass  8\n\
    FcgidMaxProcesses          100\n\
    FcgidConnectTimeout 			 20\n\
    FcgidIdleTimeout           60\n\
    FcgidProcessLifeTime       120\n\
    FcgidIdleScanInterval      10\n\
    \
    <IfModule mod_mime.c>\n\
      AddHandler fcgid-script .fcgi\n\
    </IfModule>\n\
    </IfModule>' > /etc/apache2/mods-enabled/fcgid.conf

# Create a script which runns the IP to Country lookup in the background, and runs Apache in the foreground
RUN echo '#!/bin/sh\n\
    if [ ! $NO_IP_TO_COUNTRY ]; then\n\
      echo "Running IP to Country lookup"\n\
      cd /masterserver/util && ./listcountry.pl > /masterserver/log/listcountry.log &\n\
    else\n\
      echo "Not using IP to Country lookup"\n\
    fi\n\
    cd /masterserver && apache2 -DFOREGROUND' > /masterserver/launch.sh

RUN mkdir -p /run/mod_fcgid \
    && chown -R daemon:daemon /run/mod_fcgid /masterserver \
    && chmod +x /masterserver/launch.sh

USER daemon

# Supply variables expected by Debian's Apache distribution
ENV APACHE_RUN_USER=daemon\
    APACHE_RUN_GROUP=daemon\
    APACHE_RUN_DIR=/masterserver\
    APACHE_PID_FILE=/masterserver/apache2.pid\
    APACHE_LOG_DIR=/masterserver/log\
    NO_IP_TO_COUNTRY=""

CMD ["/masterserver/launch.sh"]
