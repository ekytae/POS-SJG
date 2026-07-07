import '../../../core/api/dio_client.dart';
import 'printer_model.dart';

class PrinterService {
  Future<List<PrinterModel>> getPrinters() async {
    final dio = await DioClient.getInstance();
    final response = await dio.get('/printers');
    final List data = response.data['data'];
    return data.map((json) => PrinterModel.fromJson(json)).toList();
  }

  Future<PrinterModel> addPrinter(String name, String macAddress) async {
    final dio = await DioClient.getInstance();
    final response = await dio.post('/printers', data: {
      'name': name,
      'mac_address': macAddress,
    });
    return PrinterModel.fromJson(response.data['data']);
  }

  Future<void> setDefault(int id) async {
    final dio = await DioClient.getInstance();
    await dio.patch('/printers/$id/set-default');
  }

  Future<void> deletePrinter(int id) async {
    final dio = await DioClient.getInstance();
    await dio.delete('/printers/$id');
  }
}