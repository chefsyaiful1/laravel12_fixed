<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;
use Symfony\Component\Process\Process;

class CheckShieldUpdate extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'shield:check-update';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Check for Filament Shield v4 updates and auto-upgrade safely if compatible.';

    /**
     * Execute the console command.
     */
    public function handle(): void
    {
        $this->newLine();
        $this->info('🔍 Checking for Filament Shield updates...');

        try {
            // Step 1: Fetch latest release info from GitHub
            $response = Http::timeout(10)
                ->withHeaders(['Accept' => 'application/vnd.github.v3+json'])
                ->get('https://api.github.com/repos/bezhanSalleh/filament-shield/releases/latest');

            if (!$response->successful()) {
                $this->error('⚠️  Unable to fetch release information from GitHub.');
                return;
            }

            $latestVersion = ltrim($response->json('tag_name') ?? 'unknown', 'v');
            $this->line("📦 Latest Shield release: v{$latestVersion}");

            // Step 2: Get current installed version
            $currentVersion = trim(shell_exec('composer show bezhansalleh/filament-shield --format=json 2>nul | jq -r .versions[0]'));
            if (empty($currentVersion)) {
                $currentVersion = trim(shell_exec('composer show bezhansalleh/filament-shield | findstr versions'));
            }
            $currentVersion = str_replace(['versions :', 'v', ' '], '', $currentVersion);
            $this->line("🧩 Installed version: v" . ($currentVersion ?: 'unknown'));

            // Step 3: Compare versions
            if (version_compare($latestVersion, $currentVersion, '<=')) {
                $this->info('✅ Filament Shield is already up to date.');
                return;
            }

            // Step 4: Confirm v4 compatibility
            if (!preg_match('/^4\./', $latestVersion)) {
                $this->warn("⚠️  Latest version (v{$latestVersion}) is not a v4 release — skipping upgrade.");
                return;
            }

            // Step 5: Attempt upgrade
            $this->warn("⚡ Upgrading Filament Shield from v{$currentVersion} → v{$latestVersion} ...");

            $process = new Process([
                'composer', 'require', 'bezhansalleh/filament-shield:^4.0', '-W'
            ]);
            $process->setTimeout(600);
            $process->setIdleTimeout(60);

            $process->run(function ($type, $buffer) {
                echo $buffer;
            });

            if (!$process->isSuccessful()) {
                $this->error('❌ Upgrade failed. Check Composer output above for details.');
                return;
            }

            // Step 6: Post-upgrade housekeeping
            $this->newLine();
            $this->info('📂 Publishing updated assets...');
            $this->callSilent('vendor:publish', ['--tag' => 'filament-shield-config', '--force' => true]);
            $this->callSilent('vendor:publish', ['--tag' => 'filament-shield-migrations', '--force' => true]);

            $this->info('🧹 Clearing cache and optimizing...');
            $this->callSilent('optimize:clear');
            $this->callSilent('optimize');

            $this->newLine();
            $this->info("✅ Filament Shield successfully upgraded to v{$latestVersion}!");
            $this->line('💡 Tip: Run `php artisan shield:generate` to rebuild roles & permissions if needed.');

        } catch (\Throwable $e) {
            $this->error('❌ Error while checking or upgrading: ' . $e->getMessage());
        }

        $this->newLine();
    }
}
