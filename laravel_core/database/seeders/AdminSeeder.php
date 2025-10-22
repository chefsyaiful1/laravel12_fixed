<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 🧱 Step 1: Create or update roles
        $superAdminRole = Role::firstOrCreate(['name' => 'superadmin']);
        $userRole = Role::firstOrCreate(['name' => 'user']);

        // 🧱 Step 2: Create default permissions (extend later if needed)
        $permissions = [
            'view dashboard',
            'manage users',
            'manage roles',
            'manage settings',
        ];

        foreach ($permissions as $name) {
            Permission::firstOrCreate(['name' => $name]);
        }

        // 🧱 Step 3: Assign all permissions to superadmin
        $superAdminRole->syncPermissions(Permission::all());

        // 🧱 Step 4: Create or update the main admin user
        $admin = User::updateOrCreate(
            ['email' => 'admin@example.com'],
            [
                'name' => 'Super Admin',
                'password' => Hash::make('password'),
            ]
        );

        // 🧱 Step 5: Ensure user has the correct role
        if (!$admin->hasRole('superadmin')) {
            $admin->assignRole($superAdminRole);
        }

        // ✅ Console output
        $this->command->info('✅ Superadmin account and roles created successfully!');
        $this->command->warn('🔑 Login using: admin@example.com / password');
    }
}
