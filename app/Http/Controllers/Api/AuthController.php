<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use App\Models\User;
use App\Traits\ApiResponse;

class AuthController extends Controller
{
    use ApiResponse;

    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'username' => 'required',
            'password' => 'required'
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', $validator->errors(), 422);
        }

        if (!Auth::attempt($request->only('username', 'password'))) {
            return $this->errorResponse('Kredensial tidak valid', [], 401);
        }

        $user = User::with('role')->where('username', $request->username)->firstOrFail();

        $token = $user->createToken('auth_token')->plainTextToken;

        $data = [
            'user' => $user,
            'access_token' => $token,
            'token_type' => 'Bearer'
        ];

        return $this->successResponse($data, 'Login berhasil');
    }

    public function me(Request $request)
    {
        return $this->successResponse($request->user()->load('role'), 'Profil berhasil diambil');
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return $this->successResponse(null, 'Berhasil logout');
    }
}