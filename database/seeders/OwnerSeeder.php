<?php

namespace Database\Seeders;

use App\Models\Role;
use App\Models\User;
use Illuminate\Database\Seeder;

class OwnerSeeder extends Seeder
{
    public function run(): void
    {
        $ownerRole = Role::where('name', 'owner')->first();

        User::firstOrCreate(
            ['username' => 'admin'],
            [
                'role_id' => $ownerRole->id,
                'name' => 'Owner',
                'email' => null,
                'password' => 'password123', // otomatis ter-hash karena cast 'hashed'
                'is_active' => true,
            ]
        );
    }
}