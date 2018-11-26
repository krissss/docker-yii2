##
# This File Is Updated From base/Dockerfile By `update.php`, Don't Modify!
##

FROM php:7.1-fpm

# 安装依赖
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        git \
        supervisor \
        nginx \
        --no-install-recommends \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) \
        iconv \
        mcrypt \
        gd \
        pdo \
        pdo_mysql \
        mysqli \
        mbstring \
        opcache \
        zip \
        bcmath \
        pcntl \
    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /usr/src/php* \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 环境变量
ENV PATH=/app:/app/vendor/bin:/root/.composer/vendor/bin:$PATH \
    COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/tmp

RUN php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

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
RUN mkdir /app && chown root:root /app
WORKDIR /app

# 额外的环境变量
ENV YII_MIGRATION_DO=0 \
    # 多个路径写法：/app/web/assets\ /app/runtime
    VOLUME_PATH=''

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["docker-run.sh"]