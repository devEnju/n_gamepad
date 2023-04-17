package com.marvinvogl.n_gamepad

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorManager
import android.view.ViewGroup
import android.view.WindowManager.LayoutParams
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner

class GamepadObserver : DefaultLifecycleObserver {
    lateinit var activity: Activity
    lateinit var lifecycle: Lifecycle
    lateinit var flutterView: ViewGroup

    private lateinit var layoutParams: LayoutParams
    private lateinit var sensorManager: SensorManager

    private var gyroscopeSensor: Sensor? = null

    val gamepad = Gamepad()
    val connection = Connection(this)

    private val sensor = SensorListener(gamepad, connection)
    private val key = KeyListener(this, gamepad, connection)
    private val motion = MotionListener(gamepad, connection)

    override fun onCreate(owner: LifecycleOwner) {
        super.onCreate(owner)

        layoutParams = activity.window.attributes
        sensorManager = activity.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        gyroscopeSensor = sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE)

        val view = activity.window.decorView

        view.setOnGenericMotionListener(motion)
    }

    @SuppressLint("ResourceType")
    override fun onStart(owner: LifecycleOwner) {
        super.onStart(owner)

        flutterView = activity.window.findViewById(1)

        val view = flutterView.getChildAt(0)

        view.setOnKeyListener(key)
    }

    override fun onResume(owner: LifecycleOwner) {
        super.onResume(owner)

        connection.bind()
        if (gyroscopeSensor != null) {
            sensorManager.registerListener(sensor, gyroscopeSensor, SensorManager.SENSOR_DELAY_GAME)
        }
    }

    override fun onPause(owner: LifecycleOwner) {
        super.onPause(owner)

        if (gyroscopeSensor != null) {
            sensorManager.unregisterListener(sensor)
        }
        connection.close()
    }

    fun switchScreenBrightness(brightness: Float) {
        layoutParams.screenBrightness = brightness
        activity.window.attributes = layoutParams
    }
}
