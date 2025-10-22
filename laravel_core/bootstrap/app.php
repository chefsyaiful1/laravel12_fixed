<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // Web middleware (session, CSRF, etc.)
        $middleware->web(append: [
            // Add custom web middleware here if needed
        ]);

        // API middleware (stateless)
        $middleware->api(prepend: [
            EnsureFrontendRequestsAreStateful::class, // Sanctum support
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        // Custom exception handling if needed
    })
    ->create();
