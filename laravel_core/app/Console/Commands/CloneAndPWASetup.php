<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\File;

class CloneAndPWASetup extends Command
{
    /**
     * The name and signature of the console command.
     */
    protected $signature = 'app:clone-pwa-setup
                            {--force : Force run migrations/seeders/storage link}
                            {--fresh : Drop all tables and rerun migrations}
                            {--pwa : Setup basic PWA manifest and service worker}';

    /**
     * The console command description.
     */
    protected $description = 'Clone Laravel project, run migrations/seeders, generate APP_KEY, setup PWA and storage link.';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $force = $this->option('force');
        $fresh = $this->option('fresh');
        $pwa = $this->option('pwa');

        $this->info('🚀 Starting Clone & PWA setup...');

        // Step 0: Ensure .env exists
        if (!File::exists(base_path('.env'))) {
            $this->warn('.env file not found! Copying .env.example...');
            File::copy(base_path('.env.example'), base_path('.env'));
            $this->info('✅ .env file created.');
        }

        // Step 1: Generate APP_KEY
        $this->info('🔑 Generating APP_KEY...');
        Artisan::call('key:generate', ['--force' => true]);
        $this->line(Artisan::output());

        // Step 2: Handle migrations
        if ($fresh) {
            $this->warn('⚠️ Dropping all tables and rerunning migrations...');
            Artisan::call('migrate:fresh', ['--force' => true]);
            $this->line(Artisan::output());
        } else {
            $this->info('🗄️ Running pending migrations if any...');
            Artisan::call('migrate', ['--force' => $force]);
            $this->line(Artisan::output());
        }

        // Step 3: Seed AdminSeeder & DatabaseSeeder
        $this->info('🌱 Seeding Admin & default data...');
        Artisan::call('db:seed', ['--class' => 'AdminSeeder', '--force' => true]);
        $this->line(Artisan::output());
        Artisan::call('db:seed', ['--class' => 'DatabaseSeeder', '--force' => true]);
        $this->line(Artisan::output());

        // Step 4: Storage link
        if (!File::exists(public_path('storage')) || $force) {
            $this->info('🔗 Creating storage link...');
            Artisan::call('storage:link');
            $this->line(Artisan::output());
        }

        // Step 5: (Optional) Setup PWA
        if ($pwa) {
            $this->info('⚙️ Setting up basic PWA manifest and service worker...');
            $manifest = public_path('manifest.json');
            $serviceWorker = public_path('service-worker.js');

            if (!File::exists($manifest)) {
                File::put($manifest, json_encode([
                    'name' => config('app.name', 'Laravel App'),
                    'short_name' => config('app.name', 'Laravel'),
                    'start_url' => '/',
                    'display' => 'standalone',
                    'background_color' => '#ffffff',
                    'theme_color' => '#4A90E2',
                    'icons' => [],
                ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));
            }

            if (!File::exists($serviceWorker)) {
                File::put($serviceWorker, "// Basic service worker\nself.addEventListener('fetch', () => {});");
            }

            $this->info('✅ Basic PWA manifest and service worker created.');
        }

        $this->info('🎉 Clone & PWA setup completed successfully!');
        return Command::SUCCESS;
    }
}
