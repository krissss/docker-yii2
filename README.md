# yii2 docker

- git
- php-fpm
- nginx
- composer
- supervisor
- yii migration

## build

```bash
docker build -t yii2-docker .

docker run -v /root/www/basic/:/app -p 80:80 yii2-docker
```

## useful ENV

- YII_MIGRATION_DO [0|1]

## 问题

> 当前处于7.0.12 版本，为了和本地环境一致，另外由于部分第三方应用对 7.1 的还未兼容，问题比较多，所以降低当前 php 版本到 7.0

已知暂未支持的项目：

- [PHPOffice/PhpSpreadsheet](https://github.com/PHPOffice/PhpSpreadsheet) 还未发布正式版本
- [kartik-v/yii2-export](https://github.com/kartik-v/yii2-export) 由于使用的是[PHPOffice/PHPExcel](https://github.com/PHPOffice/PHPExcel)，所以不支持 7.1