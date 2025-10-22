<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;

class PWASetup extends Command
{
    protected $signature = 'app:pwa-setup
                            {--force : Overwrite existing PWA files if they exist}';

    protected $description = 'Setup Progressive Web App (PWA) files: manifest.json, service worker, icons';

    public function handle(): int
    {
        $force = $this->option('force');

        $this->info('🚀 Starting PWA setup...');

        // Step 1: Create manifest.json
        $manifestPath = public_path('manifest.json');
        if (!File::exists($manifestPath) || $force) {
            $manifest = [
                "name" => config('app.name', 'Laravel App'),
                "short_name" => "LaravelPWA",
                "start_url" => "/",
                "display" => "standalone",
                "background_color" => "#ffffff",
                "theme_color" => "#0d6efd",
                "icons" => [
                    [
                        "src" => "/icons/icon-192x192.png",
                        "sizes" => "192x192",
                        "type" => "image/png"
                    ],
                    [
                        "src" => "/icons/icon-512x512.png",
                        "sizes" => "512x512",
                        "type" => "image/png"
                    ]
                ]
            ];
            File::put($manifestPath, json_encode($manifest, JSON_PRETTY_PRINT));
            $this->info("✅ manifest.json created at {$manifestPath}");
        } else {
            $this->line("ℹ️ manifest.json already exists. Use --force to overwrite.");
        }

        // Step 2: Create service-worker.js
        $swPath = public_path('service-worker.js');
        if (!File::exists($swPath) || $force) {
            $swContent = <<<JS
self.addEventListener('install', function(event) {
    console.log('Service Worker installing.');
    event.waitUntil(caches.open('v1').then(function(cache) {
        return cache.addAll(['/']);
    }));
});

self.addEventListener('fetch', function(event) {
    event.respondWith(
        caches.match(event.request).then(function(response) {
            return response || fetch(event.request);
        })
    );
});
JS;
            File::put($swPath, $swContent);
            $this->info("✅ service-worker.js created at {$swPath}");
        } else {
            $this->line("ℹ️ service-worker.js already exists. Use --force to overwrite.");
        }

        // Step 3: Create icons folder
        $iconsDir = public_path('icons');
        if (!File::exists($iconsDir)) {
            File::makeDirectory($iconsDir, 0755, true);
            $this->info("✅ icons folder created at {$iconsDir}");
        } else {
            $this->line("ℹ️ icons folder already exists.");
        }

        $this->info("🎉 PWA setup complete! Next steps:");
        $this->line("- Add `<link rel=\"manifest\" href=\"/manifest.json\">` in your Blade <head>");
        $this->line("- Register the service worker in your JS:");
        $this->line("  if ('serviceWorker' in navigator) { navigator.serviceWorker.register('/service-worker.js'); }");

        return Command::SUCCESS;
    }
}
