import '../../../core/api/dio_client.dart';
import 'transaction_history_model.dart';

class HistoryService {
  Future<List<TransactionListItem>> getTransactions({
    String? search,
    String? dateFrom,
    String? dateTo,
  }) async {
    final dio = await DioClient.getInstance();

    final response = await dio.get('/transactions', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (dateFrom != null) 'date_from': dateFrom,
      if (dateTo != null) 'date_to': dateTo,
      'per_page': 50,
    });

    final List data = response.data['data']['data']; // paginated: data.data
    return data.map((json) => TransactionListItem.fromJson(json)).toList();
  }

  Future<TransactionDetailModel> getDetail(int id) async {
    final dio = await DioClient.getInstance();
    final response = await dio.get('/transactions/$id');
    return TransactionDetailModel.fromJson(response.data['data']);
  }

  Future<void> voidTransaction(int id, String? reason) async {
    final dio = await DioClient.getInstance();
    await dio.patch('/transactions/$id/void', data: {
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
  }
}