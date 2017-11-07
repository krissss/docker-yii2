# yii2 docker

- git
- php-fpm
- nginx
- composer
- supervisor

## build

```bash
docker build -t yii2-docker .

docker run -v /root/www/basic/:/app -p 80:80 yii2-docker
```