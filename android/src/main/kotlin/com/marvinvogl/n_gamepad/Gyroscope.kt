package com.marvinvogl.n_gamepad

import android.hardware.Sensor
import android.hardware.SensorEvent

class Gyroscope : Control(0b00000010) {
    private val data = FloatArray(3)

    private var x = 0f
    private var y = 0f
    private var z = 0f

    fun onEvent(event: SensorEvent): Boolean {
        if (event.sensor.type == Sensor.TYPE_GYROSCOPE) {
            data[0] = event.values[0]
            data[1] = event.values[1]
            data[2] = event.values[2]

            if (x != data[0] || y != data[1] || z != data[2]) {
                x = data[0]
                y = data[1]
                z = data[2]

                return prepareSensorData(SensorListener.buffer)
            }
        }
        return false
    }

    private fun prepareSensorData(buffer: ControlBuffer): Boolean {
        if (transmission) {
            buffer.bitfield = bitmask
            buffer.putFloatData(data)
            
            return true
        }
        return false
    }
}
