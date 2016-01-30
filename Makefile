UBUNTU_RELEASE = "14.04"
PHP_VERSION = $(shell git ls-remote --tags https://github.com/php/php-src.git | sort -t '/' -k 3 -V | awk '$$2~/php-[0-9]+\.[0-9]+\.[0-9]$$/' | tail -n1 | awk '{print $$2}' | egrep -o '[0-9]+\.[0-9]+\.[0-9]$$')
PHP_SHA = $(shell git ls-remote --tags https://github.com/php/php-src.git | sort -t '/' -k 3 -V | awk '$$2~/php-[0-9]+\.[0-9]+\.[0-9]$$/' | tail -n1 | awk '{print $$1}')

.PHONY: all build cp

all: build cp

build:
	sed "s/__UBUNTU_RELEASE__/${UBUNTU_RELEASE}/g" Dockerfile > Dockerfile-${UBUNTU_RELEASE}
	sed -i "s/__PHP_VERSION__/${PHP_VERSION}/g" Dockerfile-${UBUNTU_RELEASE}
	sed -i "s/__PHP_SHA__/${PHP_SHA}/g" Dockerfile-${UBUNTU_RELEASE}
	docker build -t php-${PHP_VERSION} -f Dockerfile-${UBUNTU_RELEASE} .

cp:
	mkdir -p ./${UBUNTU_RELEASE}
	docker create --name=php-build php-${PHP_VERSION} && docker cp php-build:/tmp/php-src-${PHP_SHA}/php-wordpress-optimized_${PHP_VERSION}-1_amd64.deb ./${UBUNTU_RELEASE}/ && docker rm -f php-build

clean:
	rm -f Dockerfile-*
