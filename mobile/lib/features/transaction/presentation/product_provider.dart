import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/product_model.dart';
import '../data/product_service.dart';

final productServiceProvider = Provider((ref) => ProductService());

// State untuk filter (search & kategori aktif)
class ProductFilterState {
  final String search;
  final int? categoryId;

  ProductFilterState({this.search = '', this.categoryId});

  ProductFilterState copyWith({String? search, int? categoryId, bool clearCategory = false}) {
    return ProductFilterState(
      search: search ?? this.search,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
    );
  }
}

class ProductFilterNotifier extends Notifier<ProductFilterState> {
  @override
  ProductFilterState build() => ProductFilterState();

  void setSearch(String value) {
    state = state.copyWith(search: value);
  }

  void setCategory(int? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(categoryId: categoryId);
    }
  }
}

final productFilterProvider = NotifierProvider<ProductFilterNotifier, ProductFilterState>(
  ProductFilterNotifier.new,
);

// FutureProvider otomatis re-fetch tiap kali productFilterProvider berubah
final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final filter = ref.watch(productFilterProvider);
  final service = ref.watch(productServiceProvider);
  return service.getProducts(search: filter.search, categoryId: filter.categoryId);
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final service = ref.watch(productServiceProvider);
  return service.getCategories();
});