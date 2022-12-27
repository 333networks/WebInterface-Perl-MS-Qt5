# Building and Running MasterServer Web UI in Docker

Running the MasterServer Web UI in Docker may be useful on systems which don't
have appropriate runtime environments available to run the web interface
natively.

## Build

From the project root directory, run:

```sh
docker build -t 333masterserver-ui:latest .
```

This will build a Docker image containing all the required dependencies and
configuration, named `333masterserver-ui`, tagged as `latest`. 

## Setup

As with the stand-alone configuration described in [README.md](README.md), you
need to also be running the MasterServer itself, since the Web UI shares access
to the database.

Importantly, the database must be readable _and writable_ by UID `1` (`daemon`)
if the IP to Country lookup us used for displaying flags in the UI.

The only other setup required is to customise `settings.pl` as desired.

Specifically, `db_login` must be customised as follows:

```perl
db_login  => ["dbi:SQLite:dbname=/masterserver/data/masterserver.db",'','']
```

## Run

Once the image is build and configuration is in place, you can run the Web UI
as follows.

Note that the service listens on port `8080` internally, any host port can then
be forwarded to this to expose it externally.

```sh
docker run --restart always --name masterserver-ui -d
  -v /path/to/masterserver.db:/masterserver/data/masterserver.db 
  -v /path/to/settings.pl:/masterserver/data/settings.pl:ro
  -p 8900:8080/tcp
  333masterserver-ui:latest
```

NOTE: If to disable the IP to Country lookup, pass set the `NO_IP_TO_COUNTRY`
environment variable, which also allows read-only mounting of the database
file, for example:

```sh
docker run --restart always --name masterserver-ui -d
  -v /path/to/masterserver.db:/masterserver/data/masterserver.db:ro 
  -v /path/to/settings.pl:/masterserver/data/settings.pl:ro
  -p 8900:8080/tcp
  -e NO_IP_TO_COUNTRY=1
  333masterserver-ui:latest
```
