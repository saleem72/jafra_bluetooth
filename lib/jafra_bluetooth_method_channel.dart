import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'jafra_bluetooth_platform_interface.dart';

/// An implementation of [JafraBluetoothPlatform] that uses method channels.
class MethodChannelJafraBluetooth extends JafraBluetoothPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('jafra_bluetooth');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
