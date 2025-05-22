// ignore_for_file: public_member_api_docs, sort_constructors_first
//

class JafraBluetoothDevice {
  final String? name;
  final String address;
  JafraBluetoothDevice({
    this.name,
    required this.address,
  });

  @override
  String toString() => 'JafraBluetoothDevice(name: $name, address: $address)';
}
