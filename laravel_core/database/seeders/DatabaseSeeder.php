<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // ✅ Step 1: Seed the Admin (superadmin + roles + permissions)
        $this->call(AdminSeeder::class);

        // ✅ Step 2: Seed a test user for development
        \App\Models\User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
        ]);

        // 🔹 Optional: Add more seeders here, e.g.,
        // $this->call(AnotherSeeder::class);

        $this->command->info('🌱 Database seeding completed successfully!');
    }
}
