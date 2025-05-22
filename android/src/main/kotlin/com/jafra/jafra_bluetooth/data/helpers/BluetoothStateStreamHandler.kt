package com.jafra.jafra_bluetooth.data.helpers

import android.bluetooth.BluetoothAdapter
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.plugin.common.EventChannel

class BluetoothStateStreamHandler(
    private val context: Context
) : EventChannel.StreamHandler {

    private var stateReceiver: BroadcastReceiver? = null
    private var eventSink: EventChannel.EventSink? = null
    private var isRegistered = false

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events

        val filter = IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED)

        stateReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == BluetoothAdapter.ACTION_STATE_CHANGED) {
                    val state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, -1)
                    val stateName = when (state) {
                        BluetoothAdapter.STATE_ON -> "on"
                        BluetoothAdapter.STATE_OFF -> "off"
                        BluetoothAdapter.STATE_TURNING_ON -> "turning_on"
                        BluetoothAdapter.STATE_TURNING_OFF -> "turning_off"
                        else -> "unknown"
                    }
                    eventSink?.success(stateName)
                }
            }
        }

        context.registerReceiver(stateReceiver, filter)
        isRegistered = true
    }

    override fun onCancel(arguments: Any?) {
        if (isRegistered && stateReceiver != null) {
            context.unregisterReceiver(stateReceiver)
            isRegistered = false
        }
        stateReceiver = null
        eventSink = null
    }
}
