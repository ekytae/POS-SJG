class CategoryModel {
  final int id;
  final String name;

  CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(id: json['id'], name: json['name']);
  }
}

class UnitModel {
  final int id;
  final String name;

  UnitModel({required this.id, required this.name});

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(id: json['id'], name: json['name']);
  }
}

class ProductModel {
  final int id;
  final String name;
  final double price;
  final int stock;
  final bool isActive;
  final CategoryModel? category;
  final UnitModel? unit;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.isActive,
    this.category,
    this.unit,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      stock: json['stock'],
      isActive: json['is_active'] ?? true,
      category: json['category'] != null ? CategoryModel.fromJson(json['category']) : null,
      unit: json['unit'] != null ? UnitModel.fromJson(json['unit']) : null,
    );
  }
}