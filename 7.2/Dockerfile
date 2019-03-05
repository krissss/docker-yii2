##
# This File Is Updated From base/Dockerfile By `update.php`, Don't Modify!
##

FROM php:7.2-fpm

## 切换镜像
#RUN sed -i "s@http://deb.debian.org@http://mirrors.aliyun.com@g" /etc/apt/sources.list \
# && sed -i 's@security.debian.org/debian-security@mirrors.aliyun.com/debian-security@g' /etc/apt/sources.list

# 安装 sqlsrv 必要的环境
# 必须的依赖
RUN apt-get update && apt-get install -y apt-transport-https gnupg2 unixodbc-dev
# @link https://docs.microsoft.com/zh-cn/sql/connect/php/installation-tutorial-linux-mac?view=sql-server-2017#installing-the-drivers-on-debian-8-and-9
RUN curl -s https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list

# 安装 nodejs
# @link https://github.com/nodesource/distributions/blob/master/README.md#deb
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
# 安装 yarn
# @link https://yarnpkg.com/en/docs/install#debian-stable
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# 安装开发环境依赖
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    apt-transport-https \
    --no-install-recommends

# 必要环境
RUN apt-get install -y \
    git \
    supervisor \
    nginx \
    unzip \
    net-tools \
    iputils-ping \
    nodejs \
    # nodejs 本机编译需要的
    build-essential \
    yarn

# php 核心扩展
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) \
        iconv \
        gd \
        pdo \
        pdo_mysql \
        mysqli \
        mbstring \
        opcache \
        zip \
        bcmath \
        
        pcntl

# 安装 sqlsrv
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17
RUN pecl install sqlsrv-5.3.0 \
    && pecl install pdo_sqlsrv-5.3.0 \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv

RUN apt-get clean \
    && apt-get autoclean \
    && apt-get autoremove \
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
    VOLUME_PATH='/app'

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["docker-run.sh"]