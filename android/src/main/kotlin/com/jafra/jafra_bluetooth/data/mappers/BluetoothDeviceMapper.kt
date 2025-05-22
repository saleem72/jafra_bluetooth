package com.jafra.jafra_bluetooth.data.mappers

import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import com.jafra.jafra_bluetooth.domain.models.JafraBluetoothDevice
import io.flutter.Log


fun getMinorDeviceClass(bluetoothClass: Int): Int {
    return bluetoothClass and 0x0000FFFF
}

@SuppressLint("MissingPermission")
fun BluetoothDevice.toJafraBluetoothDevice(): JafraBluetoothDevice {
    val deviceClass = this.bluetoothClass.deviceClass
    val majorDeviceClass = bluetoothClass.majorDeviceClass
    val minorDeviceClass = getMinorDeviceClass(deviceClass)
    val TAG = "BluetoothDevice.toJafraBluetoothDevice()"
    Log.d(TAG, "Device: $deviceClass")
    return JafraBluetoothDevice(
        name = name ?: "No Name",
        address = address,
        deviceClass = deviceClass,
        majorDeviceClass = majorDeviceClass,
        minorDeviceClass = minorDeviceClass,
    )
}


fun JafraBluetoothDevice.toMap(): HashMap<String, Any> {

    val map = HashMap<String, Any>()

    map["name"] = name
    map["address"] = address
    map["deviceClass"] = deviceClass
    map["majorDeviceClass"] = majorDeviceClass
    map["minorDeviceClass"] = minorDeviceClass

    return map
}