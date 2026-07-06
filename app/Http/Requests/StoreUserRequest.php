<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isOwner() ?? false;
    }

    public function rules(): array
    {
        $userId = $this->route('id');

        return [
            'name'     => 'required|string|max:255',
            'username' => ['required', 'string', 'max:255', Rule::unique('users', 'username')->ignore($userId)],
            'password' => $this->isMethod('post') ? 'required|string|min:6' : 'nullable|string|min:6',
            'role_id'  => 'required|exists:roles,id',
        ];
    }

    public function messages(): array
    {
        return [
            'username.unique' => 'Username sudah digunakan',
        ];
    }

    protected function failedAuthorization()
    {
        abort(response()->json([
            'success' => false,
            'message' => 'Hanya owner yang boleh mengelola akun user',
        ], 403));
    }
}