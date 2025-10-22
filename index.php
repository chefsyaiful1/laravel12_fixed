<?php

define('LARAVEL_START', microtime(true));

// Adjusted for laravel_core subfolder
require __DIR__ . '/laravel_core/vendor/autoload.php';

$app = require_once __DIR__ . '/laravel_core/bootstrap/app.php';

$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

$response = $kernel->handle(
    $request = Illuminate\Http\Request::capture()
)->send();

$kernel->terminate($request, $response);
