<?php

$base = 'base';
$commonDockerFileReplace = [
    '${COMMENT}' => "This File Is Updated From {$base}/Dockerfile By `update.php`, Don't Modify!",
    '${USE_MIRROR}' => '#', // 本地测试时使用镜像可以加速 apt-get
    '${PHP_VERSION}' => '{$VERSION}',
    'ARG PHP_VERSION' => '',
    '${MCRYPT}' => '', // php 7.2 已经完全移除 mcrypt 扩展到 pecl 中。@link http://php.net/manual/zh/migration71.deprecated.php
    '${SQLSRV_VERSION}' => '5.3.0', // 5.3.0以上版本不支持 php7.0，5.5以上可能才支持 php7.3 @link https://pecl.php.net/package/sqlsrv
    '${NODE_JS_VERSION}' => '10', // 大版本，6、8、10、11
];
$replaceFileData = [
    '7.0' => [
        '/Dockerfile' => array_merge($commonDockerFileReplace, [
            '${MCRYPT}' => 'mcrypt \\',
        ]),
    ],
    '7.1' => [
        '/Dockerfile' => array_merge($commonDockerFileReplace, [
            '${MCRYPT}' => 'mcrypt \\',
        ]),
    ],
    '7.2' => [
        '/Dockerfile' => $commonDockerFileReplace,
    ],
];

foreach ($replaceFileData as $version => $replaceFileItem) {
    rmdirs($version);
    copydir($base, $version);
    foreach ($replaceFileItem as $filename => $searchAndReplace) {
        $searchAndReplace = array_map(function ($item) use ($version) {
            return $item == '{$VERSION}' ? $version : $item;
        }, $searchAndReplace);
        replaceContent($version . $filename, $searchAndReplace);
    }
}

/**
 * 删除文件夹
 * @param $path
 * @return bool
 */
function rmdirs($path)
{
    if (!is_dir($path)) return true;
    $handle = opendir($path);
    while (($item = readdir($handle)) !== false) {
        if ($item == '.' || $item == '..') continue;
        $_path = $path . '/' . $item;
        if (is_file($_path)) unlink($_path);
        if (is_dir($_path)) rmdirs($_path);
    }
    closedir($handle);
    return rmdir($path);
}

/**
 * 复制文件夹
 * @param $source
 * @param $dest
 */
function copydir($source, $dest)
{
    if (!file_exists($dest)) mkdir($dest);
    $handle = opendir($source);
    while (($item = readdir($handle)) !== false) {
        if ($item == '.' || $item == '..') continue;
        $_source = $source . '/' . $item;
        $_dest = $dest . '/' . $item;
        if (is_file($_source)) copy($_source, $_dest);
        if (is_dir($_source)) copydir($_source, $_dest);
    }
    closedir($handle);
}

/**
 * 替换文件内容
 * @param $filename
 * @param $searchAndReplace
 */
function replaceContent($filename, $searchAndReplace)
{
    if (!file_exists($filename)) return;
    $content = file_get_contents($filename);
    $content = strtr($content, $searchAndReplace);
    file_put_contents($filename, $content);
}