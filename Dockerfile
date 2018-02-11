FROM lsiobase/xenial

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

# package versions
ARG KODI_NAME="Krypton"
ARG KODI_VER="17.6"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

# copy patches and excludes
COPY patches/ /patches/
COPY excludes /etc/dpkg/dpkg.cfg.d/excludes

# build packages variable
ARG BUILD_DEPENDENCIES="\
	ant \
	autoconf \
	automake \
	autopoint \
	autotools-dev \
	cmake	\
	curl \
	default-jdk \
	default-jre \
	gawk \
	git \
	gperf \
	libao-dev \
	libasound2-dev \
	libass-dev \
	libavahi-client-dev \
	libavahi-common-dev \
	libbluetooth-dev \
	libbz2-dev \
	libcap-dev \
	libcdio-dev \
	libcec-dev \
	libcurl4-openssl-dev \
	libcwiid-dev \
	libdbus-1-dev \
	libegl1-mesa-dev \
	libfmt3-dev \
	libfontconfig-dev \
	libfreetype6-dev \
	libfribidi-dev \
	libgif-dev \
	libgl1-mesa-dev \
	libglu1-mesa-dev \
	libglu-dev \
	libiso9660-dev \
	libjpeg-dev \
	liblcms2-dev \
	libltdl-dev \
	liblzo2-dev \
	libmicrohttpd-dev \
	libmpcdec-dev \
	libmysqlclient-dev \
	libnfs-dev \
	libpcre3-dev \
	libplist-dev \
	libpng-dev \
	libpulse-dev \
	libsmbclient-dev \
	libsqlite3-dev \
	libssh-dev \
	libssl-dev \
	libswscale-dev \
	libtag1-dev \
	libtinyxml-dev \
	libtool \
	libudev-dev \
	libusb-dev \
	libva-dev \
	libvdpau-dev \
	libxml2-dev \
	libxmu-dev \
	libxrandr-dev \
	libxslt1-dev \
	libxt-dev \
	lsb-release \
	nasm \
	python-dev \
	python-imaging \
	rapidjson-dev \
	swig \
	uuid-dev \
	yasm \
	zip \
	zlib1g-dev"

RUN \
 echo "**** add additional repositories ****" && \
 apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 828AB726 && \
 echo "deb http://ppa.launchpad.net/george-edison55/cmake-3.x/ubuntu xenial main" >> \
	/etc/apt/sources.list.d/cmake.list && \
 echo "deb-src http://ppa.launchpad.net/george-edison55/cmake-3.x/ubuntu xenial main" >> \
	/etc/apt/sources.list.d/cmake.list && \
 apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 91E7EE5E && \
 echo "deb http://ppa.launchpad.net/team-xbmc/xbmc-ppa-build-depends/ubuntu xenial main" >> \
	/etc/apt/sources.list.d/kodi.list && \
 echo "deb-src http://ppa.launchpad.net/team-xbmc/xbmc-ppa-build-depends/ubuntu xenial main" >> \
	/etc/apt/sources.list.d/kodi.list && \
 echo "**** install build packages ****" && \
 apt-get update && \
 apt-get install -y \
	$BUILD_DEPENDENCIES
RUN \
 mkdir -p \
	/tmp/bluray && \
 curl -o \
 /tmp/bluray-src.tar.bz2 -L \
	"ftp://ftp.videolan.org/pub/videolan/libbluray/1.0.2/libbluray-1.0.2.tar.bz2" && \
 tar xf \
 /tmp/bluray-src.tar.bz2 -C \
	/tmp/bluray --strip-components=1 && \
 cd /tmp/bluray && \
 ./configure \
	--prefix=/usr && \
 make && \
 make install

RUN \
 apt-get update && \
 apt-get install -y \
 mkdir -p \
	/tmp/kodi-src/kodi-build && \
 curl -o \
 /tmp/kodi.tar.gz -L \
	"https://github.com/xbmc/xbmc/archive/master.tar.gz" && \
 tar xf \
 /tmp/kodi.tar.gz -C \
	/tmp/kodi-src --strip-components=1 && \
 cd /tmp/kodi-src/kodi-build && \
 cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local && \
 cmake --build . -- VERBOSE=1
