import 'package:jafra_bluetooth/models/bluetooth_adapter_state.dart';
import 'package:jafra_bluetooth/models/jafra_bluetooth_device.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'jafra_bluetooth_method_channel.dart';

abstract class JafraBluetoothPlatform extends PlatformInterface {
  /// Constructs a JafraBluetoothPlatform.
  JafraBluetoothPlatform() : super(token: _token);

  static final Object _token = Object();

  static JafraBluetoothPlatform _instance = MethodChannelJafraBluetooth();

  /// The default instance of [JafraBluetoothPlatform] to use.
  ///
  /// Defaults to [MethodChannelJafraBluetooth].
  static JafraBluetoothPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [JafraBluetoothPlatform] when
  /// they register themselves.
  static set instance(JafraBluetoothPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> dispose() async {
    throw UnimplementedError('openSettings() has not been implemented.');
  }

  Future<String?> get adapterName;

  Future<String?> get adapterAddress;

  Future<bool> get isAvailable;

  Future<bool> get isEnabled;

  Future<BluetoothAdapterState> get state;

  Future<void> startDiscover();

  Future<void> stopDiscover();

  Stream<JafraBluetoothDevice> onDevice();

  Stream<BluetoothAdapterState> discoveredDevices() {
    throw UnimplementedError('startDiscovery() has not been implemented.');
  }

  Stream<bool> isDiscovering();

  Future<void> openSettings() {
    throw UnimplementedError('openSettings() has not been implemented.');
  }

  Future<bool> ensurePermissions() {
    throw UnimplementedError('ensurePermissions() has not been implemented.');
  }
}
