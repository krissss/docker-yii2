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
    
# 执行yii的初始脚本
RUN php init --env=Production --overwrite=n

# 定义环境变量
ENV MYSQL_PORT_3306_TCP_ADDR 192.168.18.249
ENV MYSQL_INSTANCE_NAME dockertest
ENV MYSQL_USERNAME test
ENV MYSQL_PASSWORD 123456

# 如果确定数据库已经存在，则可以执行 migrate
#RUN php yii migrate --interactive=0