package com.jafra.jafra_bluetooth.data.helpers


import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.util.Log
import io.flutter.plugin.common.EventChannel

import com.jafra.jafra_bluetooth.data.mappers.toJafraBluetoothDevice
import com.jafra.jafra_bluetooth.data.mappers.toMap

class BluetoothDiscoveryHelper(
    private val context: Context,
    private val bluetoothAdapter: BluetoothAdapter,
) : EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null
    private var isReceiverRegistered = false
    private var bluetoothReceiver: BroadcastReceiver? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        startDiscovery()
    }

    override fun onCancel(arguments: Any?) {
        stopDiscovery()
    }

    @SuppressLint("MissingPermission")
     fun startDiscovery() {
        if (bluetoothAdapter.isDiscovering) {
            bluetoothAdapter.cancelDiscovery()
        }

        if (!isReceiverRegistered) {
            val filter = IntentFilter(BluetoothDevice.ACTION_FOUND)
            context.registerReceiver(getReceiver(), filter)
            isReceiverRegistered = true
        }

        bluetoothAdapter.startDiscovery()
    }

    @SuppressLint("MissingPermission")
     fun stopDiscovery() {
        bluetoothAdapter.cancelDiscovery()
        if (isReceiverRegistered) {
            context.unregisterReceiver(bluetoothReceiver)
            isReceiverRegistered = false
        }
        eventSink = null
    }

    @Suppress("DEPRECATION")
    private fun getReceiver(): BroadcastReceiver {
        if (bluetoothReceiver == null) {
            bluetoothReceiver = object : BroadcastReceiver() {
                override fun onReceive(ctx: Context?, intent: Intent?) {
                    if (intent?.action == BluetoothDevice.ACTION_FOUND) {
                        val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            intent.getParcelableExtra(
                                BluetoothDevice.EXTRA_DEVICE,
                                BluetoothDevice::class.java
                            )
                        } else {
                            @Suppress("DEPRECATION")
                            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                        }
                        device?.let {
                            eventSink?.success(it.toJafraBluetoothDevice().toMap())
                        }

                    }
                }
            }
        }
        return bluetoothReceiver!!
    }
}