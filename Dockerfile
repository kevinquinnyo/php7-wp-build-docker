FROM ubuntu:__UBUNTU_RELEASE__
MAINTAINER Kevin Quinn "kevin.quinn@totalserversolutions.com"

ENV PHP_VERSION __PHP_VERSION__
ENV PHP_SHA __PHP_SHA__
ENV UBUNTU_RELEASE __UBUNTU_RELEASE__

# Install tools needed by install scripts below
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt-get -y update
RUN apt-get -y install gcc-5
RUN apt-get -y install curl \
	sudo \
	wget \
	build-essential \
	gcc-5 \
	libxml2-dev \
	openssl-dev \
	libssl-dev \
	libcurl4-openssl-dev \
	pkg-config \
	pkg-config \
	libpcre3-dev \
	sqlite3 \
	libsqlite3-dev \
	libbz2-dev \
	libgdbm-dev \
	libgdbm-dev \
	libdb*-dev \
	libdb4o-cil-dev \
	libjpe \
	libpng12-dev \
	libxpm-dev \
	libfreetype6-dev \
	libgd-dev \
	libgmp-dev \
	libgmp3-dev \
	libicu-dev \
	icu-devtools \
	g++ \
	mysql \
	mysql-common \
	mysql-client \
	libmysqlclient-dev \
	libpq-dev \
	libpspell-dev \
	librecode-dev \
	libqxmlrpc-dev \
	libtidy-dev \
	libxslt1-dev

# Download php
WORKDIR /tmp
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 100
RUN curl -L https://github.com/php/php-src/archive/${PHP_SHA}.tar.gz | tar xvz

# Build php
WORKDIR /tmp/php-src-${PHP_SHA}/
RUN ./configure \
	--prefix=/usr \
	--build=x86_64-linux-gnu \
	--host=x86_64-linux-gnu \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--mandir=/usr/share/man \
	--disable-debug \
	--with-regex=php \
	--disable-rpath \
	--disable-static \
	--with-pic \
	--with-layout=GNU \
	--with-pear=/usr/share/php \
	--enable-calendar \
	--enable-bcmath \
	--with-bz2 \
	--enable-ctype \
	--without-gdbm \
	--with-iconv \
	--enable-exif \
	--with-gettext \
	--enable-mbstring \
	--with-pcre-regex=/usr \
	--enable-shmop \
	--enable-sockets \
	--enable-wddx \
	--with-libxml-dir=/usr \
	--with-zlib \
	--with-kerberos=/usr \
	--with-openssl=/usr/ \
	--enable-soap \
	--enable-zip \
	--with-mhash=yes \
	--with-system-tzdata \
	--with-mysql-sock=/var/run/mysqld/mysqld.sock \
	--without-mm \
	--with-curl=shared,/usr \
	--with-zlib-dir=/usr \
	--with-gd=shared,/usr \
	--enable-gd-native-ttf \
	--with-gmp=shared,/usr \
	--with-jpeg-dir=shared,/usr \
	--with-xpm-dir=shared,/usr/X11R6 \
	--with-png-dir=shared,/usr \
	--with-freetype-dir=shared,/usr \
	--with-vpx-dir=shared,/usr \
	--enable-intl=shared \
	--without-t1lib \
	--with-mysql=shared,/usr \
	--with-mysqli=shared,/usr/bin/mysql_config \
	--with-pspell=shared,/usr \
	--with-recode=shared,/usr \
	--with-xsl=shared,/usr \
	--with-tidy=shared,/usr \
	--with-xmlrpc=shared \
	--enable-fpm

# Install wordpress to train php against
WORKDIR /tmp
RUN curl https://wordpress.org/latest.tar.gz | tar xzv

RUN apt-get -y install checkinstall
WORKDIR /tmp/php-src-${PHP_SHA}/
RUN make clean
RUN make -j2 prof-gen
RUN sapi/cgi/php -T 1000 /tmp/wordpress/index.php
RUN make prof-clean
RUN make -j2 prof-use
RUN checkinstall -y --pkgname="php-${PHP_VERSION}-${PHP_SHA}" -D make install

