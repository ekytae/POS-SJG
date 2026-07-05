namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use App\Models\User;
// use App\Traits\ApiResponse; // Pastikan trait ini di-import jika kamu membuatnya di folder Traits

class AuthController extends Controller
{
    // use ApiResponse; 

    public function login(Request $request)
    {
        // Validasi input (sesuaikan jika kamu pakai email alih-alih username)
        $validator = Validator::make($request->all(), [
            'username' => 'required',
            'password' => 'required'
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', $validator->errors(), 422);
        }

        // Cek Kredensial
        if (!Auth::attempt($request->only('username', 'password'))) {
            return $this->errorResponse('Kredensial tidak valid', [], 401);
        }

        $user = User::where('username', $request->username)->firstOrFail();

        // Generate Sanctum Token
        $token = $user->createToken('auth_token')->plainTextToken;

        $data = [
            'user' => $user,
            'access_token' => $token,
            'token_type' => 'Bearer'
        ];

        return $this->successResponse($data, 'Login berhasil');
    }
}