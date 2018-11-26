<?php
$dsn = env('DB_DSN', 'mysql:host=127.0.0.1;dbname=yii2basic');
$username = env('DB_USERNAME', 'test');
$password = env('DB_PASSWORD', '123456');

return [
    'class' => 'yii\db\Connection',
    'dsn' => $dsn,
    'username' => $username,
    'password' => $password,
    'charset' => 'utf8',
    'enableSchemaCache' => true,
    'schemaCacheDuration' => YII_DEBUG ? 60 : 3600
];