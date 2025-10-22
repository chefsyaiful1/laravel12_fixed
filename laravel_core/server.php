<?php
/**
 * Custom Router for Nested Laravel Install
 * ----------------------------------------
 * Routes requests from project root → laravel_core/public
 */

$basePath   = __DIR__;
$publicPath = $basePath . '/laravel_core/public';

// Decode requested URI
$uri = urldecode(
    parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?? '/'
);

// Serve static assets directly
$filePath = $publicPath . $uri;
if ($uri !== '/' && file_exists($filePath) && !is_dir($filePath)) {
    return false;
}

// Log request (optional)
$time = date('Y-m-d H:i:s');
$ip   = $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1';
$port = $_SERVER['REMOTE_PORT'] ?? '';
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
error_log("[$time] $ip:$port [$method] $uri");

// Load Laravel front controller
require_once $publicPath . '/index.php';
