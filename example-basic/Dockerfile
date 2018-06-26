FROM daocloud.io/krissss/docker-yii2

# 设置项目目录
WORKDIR /app

# 设置配置文件
# php
COPY ./docker/php/php.ini /usr/local/etc/php
# supervisor
COPY ./docker/supervisor/*.conf /etc/supervisor/conf.d/
# nginx
COPY ./docker/nginx/vhost.conf /etc/nginx/conf.d/vhost.conf

# 预先加载 Composer 包依赖，优化 Docker 构建镜像的速度
COPY ./composer.json /app/
COPY ./composer.lock /app/
RUN composer install --no-autoloader --no-scripts

# 复制代码到项目目录
COPY . /app

# 执行 Composer 自动加载和相关脚本
RUN composer install \
    && composer dump-autoload

# 定义环境变量
ENV YII_MIGRATION_DO=1 \
    VOLUME_PATH=/app/web/assets\ /app/runtime \
    YII_DEBUG=0 \
    DB_DSN='mysql:host=172.17.0.1;dbname=yii2basic' \
    DB_USERNAME=test \
    DB_PASSWORD=123456

# 修改目录权限
RUN set -ex \
    && for path in ${VOLUME_PATH} \
    ; do \
        mkdir -p "$path"; \
        chmod 0777 "$path"; \
        chown -R root:root "$path"; \
    done