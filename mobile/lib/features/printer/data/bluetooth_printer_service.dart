import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothDeviceInfo {
  final String name;
  final String macAddress;

  BluetoothDeviceInfo({required this.name, required this.macAddress});
}

class BluetoothPrinterService {
  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    return statuses.values.every((status) => status.isGranted || status.isLimited);
  }

  Future<List<BluetoothDeviceInfo>> getPairedDevices() async {
    final devices = await PrintBluetoothThermal.pairedBluetooths;
    return devices
        .map((d) => BluetoothDeviceInfo(name: d.name, macAddress: d.macAdress))
        .toList();
  }

  Future<bool> connect(String macAddress) async {
    return PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
  }

  Future<bool> get isConnected => PrintBluetoothThermal.connectionStatus;

  Future<void> disconnect() async {
    await PrintBluetoothThermal.disconnect;
  }

  Future<bool> printBytes(List<int> bytes) async {
    return PrintBluetoothThermal.writeBytes(bytes);
  }
}