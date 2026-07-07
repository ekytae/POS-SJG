import '../../../core/api/dio_client.dart';

class StoreSettings {
  final String storeName;
  final String? storeAddress;
  final String? storePhone;

  StoreSettings({required this.storeName, this.storeAddress, this.storePhone});

  factory StoreSettings.fromJson(Map<String, dynamic> json) {
    return StoreSettings(
      storeName: json['store_name'],
      storeAddress: json['store_address'],
      storePhone: json['store_phone'],
    );
  }
}

class StoreSettingsService {
  Future<StoreSettings> getSettings() async {
    final dio = await DioClient.getInstance();
    final response = await dio.get('/settings');
    return StoreSettings.fromJson(response.data['data']);
  }
}