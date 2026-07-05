<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use App\Traits\ApiResponse;

class SettingController extends Controller
{
    use ApiResponse;

    public function show()
    {
        $setting = Setting::current();
        return $this->successResponse($setting, 'Data pengaturan toko berhasil diambil');
    }

    public function update(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'store_name'    => 'required|string|max:255',
            'store_address' => 'nullable|string|max:500',
            'store_phone'   => 'nullable|string|max:20',
            'logo'          => 'nullable|image|max:2048', // max 2MB
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', $validator->errors(), 422);
        }

        $setting = Setting::current();
        $data = $validator->safe()->except('logo');

        if ($request->hasFile('logo')) {
            // Hapus logo lama kalau ada, supaya storage tidak menumpuk file tak terpakai
            if ($setting->logo_path) {
                Storage::disk('public')->delete($setting->logo_path);
            }

            $data['logo_path'] = $request->file('logo')->store('logos', 'public');
        }

        $setting->update($data);

        return $this->successResponse($setting->fresh(), 'Pengaturan toko berhasil diupdate');
    }
}