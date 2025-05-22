package com.jafra.jafra_bluetooth.domain.models

data class JafraBluetoothDevice(
    val name: String,
    val address: String,
    val  deviceClass : Int,
    val majorDeviceClass : Int,
    val minorDeviceClass : Int,
)
