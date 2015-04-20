#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Configure user nobody to match unRAID's settings
export DEBIAN_FRONTEND="noninteractive"
groupmod -g 100 users
usermod -u 99 nobody
usermod -g 100 nobody
usermod -d /home nobody
chown -R nobody:users /home

# Disable SSH
rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################
# Config
cat <<'EOT' > /etc/my_init.d/config.sh
#!/bin/bash
# Fix the timezone
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi

# Adjust UID and GID of nobody with environmet variables
USER_ID=${MB_USER_ID:-99}
GROUP_ID=${MB_GROUP_ID:-100}
groupmod -g $GROUP_ID users
usermod -u $USER_ID nobody
usermod -g $GROUP_ID nobody
usermod -d /home nobody
chown -R nobody:users /opt/mediabrowser/ /config/ /home/
EOT

# Emby Server
mkdir -p /etc/service/emby
cat <<'EOT' > /etc/service/emby/run
#!/bin/bash
umask 000

chown -R nobody:users /opt/mediabrowser/
cd /opt/mediabrowser/
exec /sbin/setuser nobody mono /opt/mediabrowser/MediaBrowser.Server.Mono.exe \
                                -programdata /config \
                                -ffmpeg $(which ffmpeg) \
                                -ffprobe $(which ffprobe)
EOT

chmod -R +x /etc/service/ /etc/my_init.d/

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 637D1286 
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF 
echo 'deb http://ppa.launchpad.net/apps-z/mediabrowser-daily/ubuntu trusty main' > /etc/apt/sources.list.d/mediabrowser.list 
echo 'deb http://download.mono-project.com/repo/debian wheezy/snapshots/3.10.0 main' > /etc/apt/sources.list.d/mono.list 
echo 'deb http://download.mono-project.com/repo/debian wheezy-apache24-compat main' >> /etc/apt/sources.list.d/mono.list
echo 'deb http://us.archive.ubuntu.com/ubuntu/ trusty main universe multiverse restricted' > /etc/apt/sources.list
echo 'deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates main universe multiverse restricted' >> /etc/apt/sources.list
add-apt-repository ppa:mc3man/trusty-media

# Use mirrors
# sed -i -e "s#http://[^\s]*archive.ubuntu[^\s]* #mirror://mirrors.ubuntu.com/mirrors.txt #g" /etc/apt/sources.list

# Install Dependencies
apt-get update -qq
apt-get install -qy --force-yes libmono-cil-dev \
                                mediainfo \
                                wget \
                                libsqlite3-dev \
                                libc6-dev \
                                ffmpeg \
                                imagemagick-6.q8 \
                                libmagickwand-6.q8-2 \
                                libmagickcore-6.q8-2 \
                                mediabrowser 

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
