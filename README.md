# yii2 docker

> [github 地址](https://github.com/krissss/docker-yii2)

- git
- php-fpm
- nginx
- composer
- supervisor
- yii migration

## build

```bash
# build yii2-docker
cd base
docker build -t yii2-docker --build-args PHP_VERSION=7.0 .
docker run -v /root/www/basic/:/app -p 80:80 yii2-docker

# build basic
docker build -t basic .
docker run --rm --name basic -p 81:80 -v /root/test-dir/runtime:/app/runtime -v /root/test-dir/web:/app/web/assets basic
docker stop basic

# build advanced
docker build -t advanced .
docker run --rm --name advanced -p 81:80 -v /root/test-dir2/runtime:/app/backend/runtime -v /root/test-dir2/web:/app/backend/web/assets advanced
docker stop advanced
```

## 使用方式

### 作为 yii2 环境使用

1. 在宿主机 clone 代码
2. 安装 php-cli（用于执行 yii2 的命令等）
3. 将 yii2 项目初始化，完成 composer 安装等
4. 拉取镜像容器 `daocloud.io/krissss/docker-yii2`
5. 启动容器，挂载 volume（将代码和 nginx 域名等挂载进去），修改 ENV（主要是`VOLUME_PATH` 可以解决容器和宿主机之间的权限问题）
    
    - /app：yii2 项目目录
    - /etc/nginx/conf.d：nginx 配置目录，可以放虚拟域名等配置
    - /usr/local/etc/php：php 配置目录，可以放 php.ini
    - /etc/supervisor/conf.d： supervisor 脚本目录，可以放 supervisor 的配置
    （注意：/etc/supervisor/conf.d/supervisord.conf 是存在的，其中配置了 `supervisord` `php-fpm` `nginx`，[详情见](https://github.com/krissss/docker-yii2/blob/master/image-files/etc/supervisor/conf.d/supervisord.conf)。
    所以挂载该目录时注意不要把 `supervisord.conf` 给覆盖或者取消掉了，启动容器时会报错）
    
    docker YAML：
    ```yaml
    docker-yii2-env:
      image: daocloud.io/krissss/docker-yii2:latest
      privileged: false
      restart: always
      ports:
      - 8888:80
      volumes:
      - /app:/app
      - /app/docker/nginx:/etc/nginx/conf.d:ro
      - /app/docker/php/php.ini:/usr/local/etc/php/conf.d/php.ini:ro
      - /app/docker/supervisor/queue.conf:/etc/supervisor/conf.d/queue.conf:ro
      environment:
      - VOLUME_PATH=/app
    ```
    
6. 访问应用

### 打包整个 yii2 项目使用

例子参照 [example-basic](https://github.com/krissss/docker-yii2/tree/master/example/basic) 和 [example-advanced](https://github.com/krissss/docker-yii2/tree/master/example/advanced)

## ENV

- YII_MIGRATION_DO：是否在启动容器时执行 php yii migrate，值可选：
   - `0`：不执行，
   - `1`：执行

- VOLUME_PATH：外部挂载 volume 的路径，可以解决写权限问题，值：
   - `''`：为空代表没有外部挂在
   - `/app/web/assets`：单个路径
   - `/app/runtime\ /app/web/assets`：多个路径

## 说明

1. 编译版本请使用：docker run 参数 `--build-args PHP_VERSION=7.0`

2. 7.0 7.1 7.2 下的内容 update.php 维护，请勿直接修改