//

enum BluetoothAdapterState {
  off,
  turningOn,
  on,
  turningOff,
  unknown;

  factory BluetoothAdapterState.fromCode(int code) => switch (code) {
        10 => BluetoothAdapterState.off,
        11 => BluetoothAdapterState.turningOn,
        12 => BluetoothAdapterState.on,
        13 => BluetoothAdapterState.turningOff,
        int() => throw BluetoothAdapterState.unknown,
      };
}
