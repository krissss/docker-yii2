# yii2 docker

- git
- gosu
- php-fpm
- nginx
- composer
- supervisor
- yii migration

## build

```bash
# build yii2-docker
docker build -t yii2-docker .
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

## useful ENV

- YII_MIGRATION_DO：是否在启动容器时执行 php yii migrate，值可选：
   - `0`：不执行，
   - `1`：执行

- VOLUME_PATH：外部挂载 volume 的路径，可以解决写权限问题，值：
   - `''`：为空代表没有外部挂在
   - `/app/web/assets`：单个路径
   - `/app/runtime\ /app/web/assets`：多个路径

## 问题

> 当前处于7.0.12 版本，为了和本地环境一致，另外由于部分第三方应用对 7.1 的还未兼容，问题比较多，所以降低当前 php 版本到 7.0

已知暂未支持的项目：

- [PHPOffice/PhpSpreadsheet](https://github.com/PHPOffice/PhpSpreadsheet) 还未发布正式版本
- [kartik-v/yii2-export](https://github.com/kartik-v/yii2-export) 由于使用的是[PHPOffice/PHPExcel](https://github.com/PHPOffice/PHPExcel)，所以不支持 7.1