<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\File;
use App\Models\User;

class ProjectSetup extends Command
{
    /**
     * The name and signature of the console command.
     */
    protected $signature = 'app:project-setup
                            {--force : Force run migrations and seeders}
                            {--fresh : Drop all tables and rerun migrations}';

    /**
     * The console command description.
     */
    protected $description = 'Set up Laravel project: migrations, seed Admin, storage link, clear caches, optimize, etc.';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $force = $this->option('force');
        $fresh = $this->option('fresh');

        $this->info('🚀 Starting Laravel 12 project setup...');

        // Step 0: Ensure .env exists
        if (!File::exists(base_path('.env'))) {
            $this->warn('.env file not found! Copying .env.example...');
            File::copy(base_path('.env.example'), base_path('.env'));
            $this->info('✅ .env file created. Please review and update environment variables.');
        }

        // Step 1: Optional fresh migration
        if ($fresh) {
            $this->warn('⚠️ Dropping all tables and rerunning migrations...');
            Artisan::call('migrate:fresh', ['--force' => true]);
            $this->line(Artisan::output());
        } else {
            $this->info('🗄️ Running pending migrations (if any)...');
            Artisan::call('migrate', ['--force' => $force]);
            $this->line(Artisan::output());
        }

        // Step 2: Seed AdminSeeder
        $this->info('🌱 Ensuring Superadmin exists...');
        $superadminEmail = 'admin@example.com';
        $superadmin = User::where('email', $superadminEmail)->first();
        if (!$superadmin || $force || $fresh) {
            $this->info('🛠 Creating/updating Superadmin...');
            Artisan::call('db:seed', ['--class' => 'Database\\Seeders\\AdminSeeder', '--force' => true]);
            $this->line(Artisan::output());
        } else {
            $this->line("✅ Superadmin already exists: {$superadminEmail}");
        }

        // Step 3: Seed DatabaseSeeder if forced or fresh
        if ($force || $fresh) {
            $this->info('🌱 Running DatabaseSeeder...');
            Artisan::call('db:seed', ['--class' => 'Database\\Seeders\\DatabaseSeeder', '--force' => true]);
            $this->line(Artisan::output());
        }

        // Step 4: Storage link
        if (!File::exists(public_path('storage'))) {
            $this->info('🔗 Creating storage link...');
            Artisan::call('storage:link');
            $this->line(Artisan::output());
        } else {
            $this->line('✅ Storage link already exists.');
        }

        // Step 5: Clear and optimize caches
        $this->info('🧹 Clearing caches and optimizing...');
        Artisan::call('config:clear');
        Artisan::call('route:clear');
        Artisan::call('cache:clear');
        Artisan::call('view:clear');
        Artisan::call('optimize');
        $this->line(Artisan::output());

        $this->info('✅ Laravel project setup completed successfully!');
        $this->info("🔑 Superadmin login: {$superadminEmail} / password");

        return Command::SUCCESS;
    }
}
