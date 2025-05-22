import 'package:jafra_bluetooth/models/bluetooth_adapter_state.dart';
import 'package:jafra_bluetooth/models/jafra_bluetooth_device.dart';

import 'jafra_bluetooth_platform_interface.dart';

export './models/models.dart';

class JafraBluetooth {
  JafraBluetoothPlatform get singleton => JafraBluetoothPlatform.instance;

  Future<String?> get adapterAddress => singleton.adapterAddress;

  Future<String?> get adapterName => singleton.adapterName;

  Future<bool> get isAvailable => singleton.isAvailable;

  Future<bool> get isEnabled => singleton.isEnabled;

  Future<BluetoothAdapterState> get state => singleton.state;

  Future<void> dispose() => singleton.dispose();

  Stream<BluetoothAdapterState> discoveredDevices() {
    return singleton.discoveredDevices();
  }

  Future<void> startDiscover() async => singleton.startDiscover();

  Future<void> stopDiscover() async => singleton.stopDiscover();

  Stream<bool> isDiscovering() => singleton.isDiscovering();

  Stream<JafraBluetoothDevice> onDevice() => singleton.onDevice();
}
