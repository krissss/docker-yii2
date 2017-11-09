FROM daocloud.io/library/php:7.0.12-fpm

# gosu 安装使用 github-production-release-asset-2e65be.s3.amazonaws.com 地址，国内被墙，所以使用 https 代理
# 本地编译开启，线上编译一定注释掉
#ENV http_proxy http://192.168.18.250:8118
#ENV https_proxy http://192.168.18.250:8118

# 安装composer，必须得在 gosu 之前
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/tmp \
    COMPOSER_VERSION=1.5.2
# https://github.com/composer/docker/blob/master/1.5/Dockerfile
RUN curl -s -f -L -o /tmp/installer.php https://raw.githubusercontent.com/composer/getcomposer.org/da290238de6d63faace0343efbdd5aa9354332c5/web/installer \
 && php -r " \
    \$signature = '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410'; \
    \$hash = hash('SHA384', file_get_contents('/tmp/installer.php')); \
    if (!hash_equals(\$signature, \$hash)) { \
        unlink('/tmp/installer.php'); \
        echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
        exit(1); \
    }" \
 && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
 && composer --ansi --version --no-interaction \
 && rm -rf /tmp/* /tmp/.htaccess

# 切换 apt 镜像源(本地测试打开,daocloud 线上可以注释)
#RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
#    echo "deb http://mirrors.163.codockerm/debian/ jessie main non-free contrib" >/etc/apt/sources.list && \
#    echo "deb http://mirrors.163.com/debian/ jessie-proposed-updates main non-free contrib" >/etc/apt/sources.list && \
#    echo "deb-src http://mirrors.163.com/debian/ jessie main non-free contrib" >/etc/apt/sources.list && \
#    echo "deb-src http://mirrors.163.com/debian/ jessie-proposed-updates main non-free contrib" >/etc/apt/sources.list

# gosu 解决 volume 的权限问题，参考 redis|elasticsearch 的解决方案
# https://github.com/docker-library/redis/blob/master/3.2/Dockerfile
# https://github.com/docker-library/elasticsearch/blob/master/5/docker-entrypoint.sh
# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
# 由于 php-fpm 镜像下默认就是 www-data 用户
#RUN groupadd -r www-data && useradd -r -g www-data www-data
# grab gosu for easy step-down from root
# https://github.com/tianon/gosu/releases
ENV GOSU_VERSION 1.10
# https://github.com/tianon/gosu/blob/master/INSTALL.md
RUN set -ex; \
	\
	fetchDeps=' \
		ca-certificates \
		wget \
	'; \
	apt-get update; \
	apt-get install -y --no-install-recommends $fetchDeps; \
	rm -rf /var/lib/apt/lists/*; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
	chmod +x /usr/local/bin/gosu; \
	gosu nobody true; \
	\
	apt-get purge -y --auto-remove $fetchDeps

# 安装依赖
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        git \
        supervisor \
        nginx \
        --no-install-recommends \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
    && docker-php-ext-install \
        gd \
        pdo_mysql \
        mbstring \
        mcrypt \
        opcache \
        zip \
        bcmath \
    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /usr/src/php* \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 取消代理，配合前面 gosu 安装需要代理的
#ENV http_proxy ''
#ENV https_proxy ''

# 设置时区
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo 'Asia/Shanghai' >/etc/timezone

# 系统配置文件替换
COPY image-files/ /
RUN rm -rf /etc/nginx/sites-enabled/default /etc/nginx/sites-aviable/default

# 操作权限
RUN chmod 700 \
    /usr/local/bin/docker-entrypoint.sh \
    /usr/local/bin/docker-run.sh

# 项目目录
RUN mkdir /app && chown www-data:www-data /app
WORKDIR /app

# 额外的环境变量
ENV YII_MIGRATION_DO=0 \
    # 多个路径写法：(/app/web/assets /app/runtime)
    VOLUME_PATH=()

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/local/bin/docker-run.sh"]