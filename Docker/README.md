#docker MBServer

## Description:

This is a Dockerfile for "MediaBrowser Server" - (http://mediabrowser.tv/)

## Build from docker file:

```
git clone --depth=1 https://github.com/MediaBrowser/MediaBrowser.git 
rd MediaBrowser/Docker
docker build --rm=true -t mbserver . 
```

## Volumes:

#### `/config`

Configuration files and state of MediaBrowser Server folder. (i.e. /opt/appdata/mediabrowser)

## Environment Variables:

### `TZ`

TimeZone. (i.e America/Edmonton)

### `MB_USER_ID`

User ID mediabrowser should run under, default is 99 for unRAID compatiability.

### `MB_GROUP_ID`

Group ID mediabrowser should run under, default is 100 for unRAID compatiability.

## Docker run command:

```
docker run -d --net=host -v /*your_config_location*:/config -v /*your_media_location*:/media -e TZ=<TIMEZONE> --name=mbserver mediabrowser/mbserver

```

## Other info:

### Restarting mediabrowser

```
docker exec mbserver circusctl restart MediaBrowser
```	
