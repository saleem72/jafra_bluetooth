import 'package:jafra_bluetooth/models/bluetooth_adapter_state.dart';

import 'jafra_bluetooth_platform_interface.dart';

export './models/models.dart';

class JafraBluetooth {
  JafraBluetoothPlatform get singleton => JafraBluetoothPlatform.instance;

  Future<String?> get adapterAddress => singleton.adapterAddress;

  Future<String?> get adapterName => singleton.adapterName;

  Future<bool> get isAvailable => singleton.isAvailable;

  Future<bool> get isEnabled => singleton.isEnabled;

  Future<BluetoothAdapterState> get state => singleton.state;
}
