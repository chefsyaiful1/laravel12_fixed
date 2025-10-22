<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;
use Illuminate\Support\Facades\File;
use ReflectionClass;

class Kernel extends ConsoleKernel
{
    /**
     * The Artisan commands provided by your application.
     *
     * Automatically registers all classes in app/Console/Commands that extend Command.
     *
     * @var array<int, class-string>
     */
    protected $commands = [];

    /**
     * Define the application's command schedule.
     */
    protected function schedule(Schedule $schedule): void
    {
        // Example: $schedule->command('app:project-setup --force')->daily();
        // Add your scheduled tasks here
    }

    /**
     * Register the commands for the application.
     */
    protected function commands(): void
    {
        $commandsPath = __DIR__ . '/Commands';

        // Auto-load all command classes in Commands folder
        foreach (File::allFiles($commandsPath) as $file) {
            $class = 'App\\Console\\Commands\\' . $file->getBasename('.php');

            if (class_exists($class)) {
                $reflection = new ReflectionClass($class);
                if ($reflection->isSubclassOf(\Illuminate\Console\Command::class) && !$reflection->isAbstract()) {
                    $this->commands[] = $class;
                }
            }
        }

        $this->load($commandsPath);
        require base_path('routes/console.php');
    }
}
