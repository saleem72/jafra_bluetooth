package com.jafra.jafra_bluetooth.data.helpers

import android.bluetooth.BluetoothAdapter
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.Log
import io.flutter.plugin.common.EventChannel

class BluetoothIsDiscoveringStreamHandler(
    private val context: Context
) : EventChannel.StreamHandler {


    companion object {
        const val  TAG = "JafraBluetoothPlugin"
    }

    private var stateReceiver: BroadcastReceiver? = null
    private var eventSink: EventChannel.EventSink? = null
    private var isRegistered = false


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        Log.d(TAG, "BluetoothIsDiscoveringStreamHandler: onListen")
        val filter = IntentFilter().apply {
            addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
            addAction(BluetoothAdapter.ACTION_DISCOVERY_STARTED)
        }

        stateReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val action = intent?.action
                Log.d(TAG, "BluetoothIsDiscoveringStreamHandler: $action")
                when (intent?.action) {
                    BluetoothAdapter.ACTION_DISCOVERY_STARTED -> {
                        Log.d(TAG, "BluetoothIsDiscoveringStreamHandler: ACTION_DISCOVERY_STARTED")
                        eventSink?.success(true)
                    }
                    BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                        Log.d(TAG, "BluetoothIsDiscoveringStreamHandler: ACTION_DISCOVERY_FINISHED")
                        eventSink?.success(false)
                    }
                }
            }
        }

        context.registerReceiver(stateReceiver, filter)
        Log.d(TAG, "onListen: stateReceiver has been registered")
        isRegistered = true
    }

    override fun onCancel(arguments: Any?) {
        Log.d(TAG, ": onCancel")
        if (isRegistered && stateReceiver != null) {
            context.unregisterReceiver(stateReceiver)
            isRegistered = false
        }
        stateReceiver = null
        eventSink = null
    }
}