import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/storage/local_storage.dart';
import 'user_model.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthService {
  Future<UserModel> login(String username, String password) async {
    final dio = await DioClient.getInstance();

    try {
      final response = await dio.post('/login', data: {
        'username': username,
        'password': password,
      });

      final data = response.data['data'];
      final token = data['access_token'];
      final userJson = data['user'];

      await LocalStorage.saveAuth(token, userJson);

      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Login gagal, periksa koneksi Anda';
      throw AuthException(message);
    }
  }

  Future<void> logout() async {
    final dio = await DioClient.getInstance();
    try {
      await dio.post('/logout');
    } catch (_) {
      // Tetap clear local storage walau request logout gagal (misal offline)
    }
    await LocalStorage.clear();
  }

  Future<UserModel?> getCurrentUser() async {
    final userData = await LocalStorage.getUser();
    if (userData == null) return null;
    return UserModel.fromJson(userData);
  }
}