<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreUserRequest;
use App\Models\User;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class UserController extends Controller
{
    use ApiResponse;

    public function index()
    {
        $users = User::with('role')->get();
        return $this->successResponse($users, 'Data user berhasil diambil');
    }

    public function store(StoreUserRequest $request)
    {
        $user = User::create($request->validated());
        $user->load('role');

        return $this->successResponse($user, 'User berhasil ditambahkan', 201);
    }

    public function update(StoreUserRequest $request, $id)
    {
        $user = User::find($id);

        if (!$user) {
            return $this->errorResponse('User tidak ditemukan', [], 404);
        }

        $data = $request->validated();

        if (empty($data['password'])) {
            unset($data['password']);
        }

        $user->update($data);
        $user->load('role');

        return $this->successResponse($user, 'User berhasil diupdate');
    }

    public function toggleActive(Request $request, $id)
    {
        $user = User::find($id);

        if (!$user) {
            return $this->errorResponse('User tidak ditemukan', [], 404);
        }

        if ($user->id === $request->user()->id) {
            return $this->errorResponse('Anda tidak bisa menonaktifkan akun sendiri', [], 400);
        }

        $user->update(['is_active' => !$user->is_active]);

        return $this->successResponse($user, $user->is_active ? 'User berhasil diaktifkan' : 'User berhasil dinonaktifkan');
    }
}