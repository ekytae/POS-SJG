import '../../../core/api/dio_client.dart';
import 'product_model.dart';

class ProductService {
  Future<List<ProductModel>> getProducts({String? search, int? categoryId}) async {
    final dio = await DioClient.getInstance();

    final response = await dio.get('/products', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (categoryId != null) 'category_id': categoryId,
      'is_active': 1,
    });

    final List data = response.data['data'];
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<List<CategoryModel>> getCategories() async {
    final dio = await DioClient.getInstance();
    final response = await dio.get('/categories');
    final List data = response.data['data'];
    return data.map((json) => CategoryModel.fromJson(json)).toList();
  }
}