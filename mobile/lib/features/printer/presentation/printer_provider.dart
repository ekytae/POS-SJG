import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/printer_model.dart';
import '../data/printer_service.dart';
import '../data/bluetooth_printer_service.dart';
import '../data/store_settings_service.dart';

final printerServiceProvider = Provider((ref) => PrinterService());
final bluetoothPrinterServiceProvider = Provider((ref) => BluetoothPrinterService());
final storeSettingsServiceProvider = Provider((ref) => StoreSettingsService());

final printersProvider = FutureProvider<List<PrinterModel>>((ref) async {
  final service = ref.watch(printerServiceProvider);
  return service.getPrinters();
});

final storeSettingsProvider = FutureProvider((ref) async {
  final service = ref.watch(storeSettingsServiceProvider);
  return service.getSettings();
});