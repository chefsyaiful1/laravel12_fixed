<?php

// ------------------------------------------------------------
// Custom router for PHP built-in server (Laravel proxy)
// ------------------------------------------------------------
$publicPath = __DIR__ . '/laravel_core/public';

$uri = urldecode(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?? '');

// Emulate Apache mod_rewrite: serve existing files directly
if ($uri !== '/' && file_exists($publicPath . $uri)) {
    return false;
}

// Simple request log to console
$datetime = date('Y-m-d H:i:s');
$remote = $_SERVER['REMOTE_ADDR'] ?? 'CLI';
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
file_put_contents('php://stdout', "[$datetime] $remote [$method] $uri\n");

require_once $publicPath . '/index.php';
