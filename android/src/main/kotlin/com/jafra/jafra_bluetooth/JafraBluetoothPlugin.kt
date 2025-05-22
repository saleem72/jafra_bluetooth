package com.jafra.jafra_bluetooth

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.jafra.jafra_bluetooth.data.helpers.BluetoothDiscoveryHelper
import com.jafra.jafra_bluetooth.data.helpers.BluetoothIsDiscoveringStreamHandler
import com.jafra.jafra_bluetooth.data.helpers.BluetoothStateStreamHandler
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** JafraBluetoothPlugin */
class JafraBluetoothPlugin: FlutterPlugin, MethodCallHandler, ActivityAware,
  PluginRegistry.RequestPermissionsResultListener {
  companion object {
    const val TAG = "JafraBluetoothPlugin"
    const val REQUEST_BLUETOOTH_PERMISSIONS = 1001
    const val channelName = "jafra_bluetooth"
    const val discoveryChannelName = "discovery"
    const val adapterStateChannelName = "adapter_state"
    const val isDiscoveringChannelName = "is_discovering"

    const val isAvailable = "isAvailable"
    const val isOn = "isOn"
    const val isEnabled = "isEnabled"
    const val openSettings = "openSettings"
    const val getState = "getState"
    const val getAddress = "getAddress"
    const val getName = "getName"
    const val startDiscovery = "startDiscovery"
    const val stopDiscovery = "stopDiscovery"

//    const val ensurePermissions = "ensurePermissions"
  }


  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var bluetoothAdapter: BluetoothAdapter
  private lateinit var context: Context
  private var activity: Activity? = null

  private lateinit var channel: MethodChannel
  private lateinit var discoveryChannel: EventChannel

  private lateinit var adapterStateChannel: EventChannel
  private lateinit var isDiscoveringChannel: EventChannel

  private lateinit var bluetoothDiscoveryHelper: BluetoothDiscoveryHelper
  private lateinit var adapterStateHandler: BluetoothStateStreamHandler
  private lateinit var bluetoothIsDiscoveringStreamHandler: BluetoothIsDiscoveringStreamHandler

  private var pendingOnGranted: (() -> Unit)? = null
  private var pendingOnDenied: ((String) -> Unit)? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(
      flutterPluginBinding.binaryMessenger,
      channelName
    )
    channel.setMethodCallHandler(this)
    bluetoothAdapter = getBluetoothAdapter(context)

    discoveryChannel = EventChannel(
      flutterPluginBinding.binaryMessenger,
      "$channelName/$discoveryChannelName"
    )
    bluetoothDiscoveryHelper = BluetoothDiscoveryHelper(context, bluetoothAdapter)
    discoveryChannel.setStreamHandler(bluetoothDiscoveryHelper)

    adapterStateChannel = EventChannel(
      flutterPluginBinding.binaryMessenger,
      "$channelName/$adapterStateChannelName"
    )

    adapterStateHandler = BluetoothStateStreamHandler(flutterPluginBinding.applicationContext)

    adapterStateChannel.setStreamHandler(adapterStateHandler)

    isDiscoveringChannel = EventChannel(
      flutterPluginBinding.binaryMessenger,
      "$channelName/$isDiscoveringChannelName"
    )

    bluetoothIsDiscoveringStreamHandler = BluetoothIsDiscoveringStreamHandler(context)
    isDiscoveringChannel.setStreamHandler(bluetoothIsDiscoveringStreamHandler)

    Log.d(TAG, "onAttachedToEngine: JafraBluetoothPlugin was created")
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {

      isAvailable -> {
        return result.success(true)
      }


      isOn, isEnabled -> {
        result.success(bluetoothAdapter.isEnabled)
      }


      openSettings -> {
        val intent = Intent(Settings.ACTION_BLUETOOTH_SETTINGS)
        ContextCompat.startActivity(
          context,
          intent,
          null,
        )

        result.success(null)
      }

      getState -> {
        ensureBluetoothPermissions(


          onGranted = {

            val aState = bluetoothAdapter.state
            result.success(aState)
          },
          onDenied = { error ->
            Log.d(TAG, "onMethodCall: $error")
            result.success(null)
          }
        )
      }


      getName -> {
        ensureBluetoothPermissions(


          onGranted = {

            val name = bluetoothAdapter.name
            Log.d(TAG, "onMethodCall: name: $name")
            result.success(name)
          },
          onDenied = { error ->
            Log.d(TAG, "onMethodCall: $error")
            result.success(null)
          }
        )
      }

      getAddress -> {
        result.success("mac address is hidden by system")
      }

      startDiscovery -> {
        Log.d(TAG, "onMethodCall: startDiscovery")
//        bluetoothAdapter.startDiscovery()
        bluetoothDiscoveryHelper.startDiscovery()
      }

      stopDiscovery -> {
        Log.d(TAG, "onMethodCall: stopDiscovery")
//        bluetoothAdapter.cancelDiscovery()
        bluetoothDiscoveryHelper.stopDiscovery()
      }

      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)


    discoveryChannel.setStreamHandler(null)
    bluetoothDiscoveryHelper.stopDiscovery()

    adapterStateChannel.setStreamHandler(null)
    isDiscoveringChannel.setStreamHandler(null)
  }

  override fun onRequestPermissionsResult(
    requestCode: Int, permissions: Array<out String>, grantResults: IntArray
  ): Boolean {
    if (requestCode == REQUEST_BLUETOOTH_PERMISSIONS) {
      val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
      if (allGranted) {
        pendingOnGranted?.invoke()
      } else {
        pendingOnDenied?.invoke("One or more Bluetooth permissions denied.")
      }
      pendingOnGranted = null
      pendingOnDenied = null
      return true
    }
    return false
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addRequestPermissionsResultListener(this)
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

    activity = binding.activity
    binding.addRequestPermissionsResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {

    activity = null
  }

  private fun getBluetoothAdapter(context: Context): BluetoothAdapter {
    val bluetoothManager =
      context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
    return bluetoothManager?.adapter ?: throw IllegalStateException("Bluetooth not supported")
  }


  private fun ensureBluetoothPermissions(
    onGranted: () -> Unit,
    onDenied: ((errorMessage: String) -> Unit)? = null
  ) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      val requiredPermissions = listOf(
        Manifest.permission.BLUETOOTH_CONNECT,
        Manifest.permission.BLUETOOTH_SCAN,
        Manifest.permission.ACCESS_FINE_LOCATION,
        Manifest.permission.BLUETOOTH_ADMIN,
      )

      val missingPermissions = requiredPermissions.filter {
        ContextCompat.checkSelfPermission(context, it) != PackageManager.PERMISSION_GRANTED
      }

      if (missingPermissions.isNotEmpty()) {
        if (activity != null) {
          ActivityCompat.requestPermissions(
            activity!!,
            missingPermissions.toTypedArray(),
            REQUEST_BLUETOOTH_PERMISSIONS
          )
          pendingOnGranted = onGranted
          pendingOnDenied = onDenied
        } else {
          onDenied?.invoke("Plugin not attached to an activity.")
        }
        return
      }
    }

    // All required permissions are already granted or not needed
    onGranted()
  }
}
