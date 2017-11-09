<?php
require(__DIR__ . '/../config/global.php');

$isYiiDebug = (bool)env('YII_DEBUG', true);

// comment out the following two lines when deployed to production
defined('YII_DEBUG') or define('YII_DEBUG', $isYiiDebug);
defined('YII_ENV') or define('YII_ENV', $isYiiDebug ? 'dev' : 'prod');

require(__DIR__ . '/../vendor/autoload.php');
require(__DIR__ . '/../vendor/yiisoft/yii2/Yii.php');

$config = require(__DIR__ . '/../config/web.php');

(new yii\web\Application($config))->run();
