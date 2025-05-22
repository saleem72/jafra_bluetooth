//

import 'package:equatable/equatable.dart';

class JafraBluetoothDevice extends Equatable {
  final String? name;
  final String address;

  final int deviceClass;
  final int majorDeviceClass;
  final int minorDeviceClass;

  JafraBluetoothDevice({
    this.name,
    required this.address,
    required this.deviceClass,
    required this.majorDeviceClass,
    required this.minorDeviceClass,
  });

  factory JafraBluetoothDevice.fromMap(dynamic data) {
    return JafraBluetoothDevice(
      name: data["name"],
      address: data["address"],
      deviceClass: data["deviceClass"],
      majorDeviceClass: data["majorDeviceClass"],
      minorDeviceClass: data["minorDeviceClass"],
    );
  }

  @override
  String toString() => 'JafraBluetoothDevice(name: $name, address: $address)';

  @override
  List<Object?> get props => [address];
}
