
import 'jafra_bluetooth_platform_interface.dart';

class JafraBluetooth {
  Future<String?> getPlatformVersion() {
    return JafraBluetoothPlatform.instance.getPlatformVersion();
  }
}
