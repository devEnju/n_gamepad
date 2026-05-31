package com.marvinvogl.n_gamepad

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener

class SensorListener(
    private val connection: Connection,
) : SensorEventListener {
    companion object {
        val buffer = ControlBuffer(26, 2, 0b0010)
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event != null) {
            Gamepad.gyroscope.onEvent(event)
            Gamepad.accelerometer.onEvent(event)

            connection.send(buffer)
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
}
