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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
