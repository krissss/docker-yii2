<?php

$base = 'base';
$versions = ['7.0', '7.1', '7.2'];
$replaceFiles = [
    '/Dockerfile' => [
        '${COMMENT}' => "This File Is Updated From {$base}/Dockerfile By `update.php`, Don't Modify!",
        '${PHP_VERSION}' => '{$VERSION}',
        'ARG PHP_VERSION' => '',
    ],
];

foreach ($versions as $version) {
    rmdirs($version);
    copydir($base, $version);
    foreach ($replaceFiles as $filename => $searchAndReplace) {
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