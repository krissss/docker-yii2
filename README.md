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
