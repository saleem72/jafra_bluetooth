//

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:jafra_bluetooth/jafra_bluetooth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _jafraBluetoothPlugin = JafraBluetooth();
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<bool>? _isDiscoveringSubscription;
  StreamSubscription<JafraBluetoothDevice>? _devicesSubscription;
  String adapterName = 'Unknown';
  BluetoothAdapterState adapterState = BluetoothAdapterState.unknown;
  List<JafraBluetoothDevice> devices = [];
  bool isDiscovering = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _jafraBluetoothPlugin.adapterName ?? 'Unknown platform version';
      adapterState = await _jafraBluetoothPlugin.state;
      _adapterStateSubscription =
          _jafraBluetoothPlugin.discoveredDevices().listen((r) {
        setState(() {
          adapterState = r;
        });
      });

      _isDiscoveringSubscription =
          _jafraBluetoothPlugin.isDiscovering().listen((event) {
        setState(() {
          isDiscovering = event;
        });
      });

      _devicesSubscription = _jafraBluetoothPlugin.onDevice().listen((event) {
        devices.add(event);
        setState(() {});
      });
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      adapterName = platformVersion;
    });
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    _jafraBluetoothPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Stack(
          children: [
            _buildContent(context),
            isDiscovering
                ? Container(
                    color: Colors.black38,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FilledButton(
                onPressed: () => _jafraBluetoothPlugin.startDiscover(),
                child: const Text('Start discover'),
              ),
              FilledButton(
                onPressed: () => _jafraBluetoothPlugin.stopDiscover(),
                child: const Text('Stop discover'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KeyValueWidget(
                label: 'Adapter name',
                value: adapterName,
              ),
              const SizedBox(height: 8),
              KeyValueWidget(
                label: 'Adapter state',
                value: adapterState.toString(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Devices',
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: devices.length,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 16);
              },
              itemBuilder: (BuildContext context, int index) {
                final device = devices[index];
                return DeviceTile(device: device);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DeviceTile extends StatelessWidget {
  const DeviceTile({
    super.key,
    required this.device,
  });

  final JafraBluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(device.name ?? '????'),
        Text(device.address),
        Text(
            '${device.deviceClass}, ${device.majorDeviceClass}, ${device.minorDeviceClass}, ')
      ],
    );
  }
}

class KeyValueWidget extends StatelessWidget {
  const KeyValueWidget({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

extension ContextDetails on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}
