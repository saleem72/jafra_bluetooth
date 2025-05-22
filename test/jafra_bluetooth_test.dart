import 'package:flutter_test/flutter_test.dart';
import 'package:jafra_bluetooth/jafra_bluetooth.dart';
import 'package:jafra_bluetooth/jafra_bluetooth_platform_interface.dart';
import 'package:jafra_bluetooth/jafra_bluetooth_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockJafraBluetoothPlatform
    with MockPlatformInterfaceMixin
    implements JafraBluetoothPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final JafraBluetoothPlatform initialPlatform = JafraBluetoothPlatform.instance;

  test('$MethodChannelJafraBluetooth is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelJafraBluetooth>());
  });

  test('getPlatformVersion', () async {
    JafraBluetooth jafraBluetoothPlugin = JafraBluetooth();
    MockJafraBluetoothPlatform fakePlatform = MockJafraBluetoothPlatform();
    JafraBluetoothPlatform.instance = fakePlatform;

    expect(await jafraBluetoothPlugin.getPlatformVersion(), '42');
  });
}
