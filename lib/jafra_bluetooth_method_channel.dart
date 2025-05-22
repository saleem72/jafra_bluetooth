import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:jafra_bluetooth/models/bluetooth_adapter_state.dart';

import 'jafra_bluetooth_platform_interface.dart';

/// An implementation of [JafraBluetoothPlatform] that uses method channels.
class MethodChannelJafraBluetooth extends JafraBluetoothPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(_BluetoothKeys.channelName);

  @override
  Future<String?> get adapterAddress async =>
      await methodChannel.invokeMethod<String>(_BluetoothKeys.getAddress);

  @override
  Future<String?> get adapterName async =>
      await methodChannel.invokeMethod<String>(_BluetoothKeys.getName);

  @override
  Future<bool> get isAvailable async =>
      (await methodChannel.invokeMethod<bool>(_BluetoothKeys.isAvailable)) ??
      false;

  @override

  ///  Bluetooth adapter is On.
  Future<bool> get isEnabled async =>
      (await methodChannel.invokeMethod<bool>(_BluetoothKeys.isEnabled)) ??
      false;

  @override

  /// State of the Bluetooth adapter.
  Future<BluetoothAdapterState> get state async =>
      BluetoothAdapterState.fromCode(
          await methodChannel.invokeMethod(_BluetoothKeys.getState));
}

abstract class _BluetoothKeys {
  static const String channelName = 'jafra_bluetooth';
  static const String isAvailable = 'isAvailable';
  static const String isOn = 'isOn';
  static const String isEnabled = 'isEnabled';
  static const String openSettings = 'openSettings';
  static const String getState = 'getState';
  static const String getAddress = 'getAddress';
  static const String getName = 'getName';
}
