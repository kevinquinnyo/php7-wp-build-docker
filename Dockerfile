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
	autoconf \
	automake \
	libtool \
	re2c \
	flex \
	bison \
	gcc-5 \
	libxml2-dev \
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
	libpng12-dev \
	libxpm-dev \
	libfreetype6-dev \
	libgd-dev \
	libgmp-dev \
	libgmp3-dev \
	libicu-dev \
	icu-devtools \
	g++ \
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
RUN rm -rf /usr/local/include && ln -fs /usr/include/x86_64-linux-gnu /usr/local/include
WORKDIR /tmp/php-src-${PHP_SHA}/
RUN ./buildconf --force
RUN ./configure \
	--prefix=/usr \
	--build=x86_64-linux-gnu \
	--host=x86_64-linux-gnu \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--mandir=/usr/share/man \
	--disable-debug \
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
	--with-pcre-regex \
	--enable-shmop \
	--enable-sockets \
	--enable-wddx \
	--with-libxml-dir=/usr \
	--with-zlib \
	--with-kerberos=/usr \
	--with-openssl \
	--with-openssl-dir=/usr/lib/x86_64-linux-gnu/openssl-1.0.0/ \
	--enable-soap \
	--enable-zip \
	--with-mhash=yes \
	--with-mysql-sock=/var/run/mysqld/mysqld.sock \
	--without-mm \
	--with-curl=shared,/usr \
	--with-zlib-dir=/usr \
	--with-gd=shared,/usr \
	--enable-gd-native-ttf \
	--with-gmp=shared \
	--with-jpeg-dir=shared,/usr \
	--with-xpm-dir=shared,/usr/X11R6 \
	--with-png-dir=shared,/usr \
	--with-freetype-dir=shared,/usr \
	--enable-intl=shared \
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
RUN sapi/cgi/php-cgi -T 1000 /tmp/wordpress/index.php
RUN make prof-clean
RUN make -j2 prof-use
RUN checkinstall -y -D --pkgversion=${PHP_VERSION} \
	--pkgname="php-wordpress-optimized" \
	--pkgrelease=${PHP_RELEASE} \
	--maintainer="kevin.quinn@totalserversolutions.com" \
	 make install

