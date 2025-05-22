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
  String _platformVersion = 'Unknown';
  final _jafraBluetoothPlugin = JafraBluetooth();
  StreamSubscription<BluetoothAdapterState>? _streamSubscription;
  BluetoothAdapterState adapterState = BluetoothAdapterState.unknown;

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
      _streamSubscription = _jafraBluetoothPlugin.startDiscovery().listen((r) {
        setState(() {
          adapterState = r;
        });
      });
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
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
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Adapter name: $_platformVersion'),
              Text('Adapter state: ${adapterState.toString()}'),
            ],
          ),
        ),
      ),
    );
  }
}
