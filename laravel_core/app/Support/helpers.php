<?php

// Global helper functions for your Laravel app.
// You can safely add custom functions here later.

if (!function_exists('app_version')) {
    function app_version(): string
    {
        return \Illuminate\Foundation\Application::VERSION;
    }
}
