class PrinterModel {
  final int id;
  final String name;
  final String macAddress;
  final bool isDefault;

  PrinterModel({
    required this.id,
    required this.name,
    required this.macAddress,
    required this.isDefault,
  });

  factory PrinterModel.fromJson(Map<String, dynamic> json) {
    return PrinterModel(
      id: json['id'],
      name: json['name'],
      macAddress: json['mac_address'],
      isDefault: json['is_default'] ?? false,
    );
  }
}