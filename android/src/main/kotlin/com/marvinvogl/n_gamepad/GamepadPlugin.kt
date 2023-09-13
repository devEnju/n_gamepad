package com.marvinvogl.n_gamepad

import android.view.WindowManager.LayoutParams
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.net.InetAddress
import java.net.InetSocketAddress

/** GamepadPlugin */
class GamepadPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    companion object {
        private const val METHOD = "com.marvinvogl.n_gamepad/method"
        private const val DPAD = "com.marvinvogl.n_gamepad/dpad"
        private const val JOYSTICK_LEFT = "com.marvinvogl.n_gamepad/joystickLeft"
        private const val JOYSTICK_RIGHT = "com.marvinvogl.n_gamepad/joystickRight"
        private const val TRIGGER_LEFT = "com.marvinvogl.n_gamepad/triggerLeft"
        private const val TRIGGER_RIGHT = "com.marvinvogl.n_gamepad/triggerRight"
    }
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var dpadChannel: EventChannel
    private lateinit var joystickLeftChannel: EventChannel
    private lateinit var joystickRightChannel: EventChannel
    private lateinit var triggerLeftChannel: EventChannel
    private lateinit var triggerRightChannel: EventChannel

    private val observer = GamepadObserver()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD)
        dpadChannel = EventChannel(flutterPluginBinding.binaryMessenger, DPAD)
        joystickLeftChannel = EventChannel(flutterPluginBinding.binaryMessenger, JOYSTICK_LEFT)
        joystickRightChannel = EventChannel(flutterPluginBinding.binaryMessenger, JOYSTICK_RIGHT)
        triggerLeftChannel = EventChannel(flutterPluginBinding.binaryMessenger, TRIGGER_LEFT)
        triggerRightChannel = EventChannel(flutterPluginBinding.binaryMessenger, TRIGGER_RIGHT)

        channel.setMethodCallHandler(this)
        dpadChannel.setStreamHandler(observer.gamepad.dpad)
        joystickLeftChannel.setStreamHandler(observer.gamepad.joystickLeft)
        joystickRightChannel.setStreamHandler(observer.gamepad.joystickRight)
        triggerLeftChannel.setStreamHandler(observer.gamepad.triggerLeft)
        triggerRightChannel.setStreamHandler(observer.gamepad.triggerRight)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        dpadChannel.setStreamHandler(null)
        joystickLeftChannel.setStreamHandler(null)
        joystickRightChannel.setStreamHandler(null)
        triggerLeftChannel.setStreamHandler(null)
        triggerRightChannel.setStreamHandler(null)

        observer.gamepad.dpad.onCancel(null)
        observer.gamepad.joystickLeft.onCancel(null)
        observer.gamepad.joystickRight.onCancel(null)
        observer.gamepad.triggerLeft.onCancel(null)
        observer.gamepad.triggerRight.onCancel(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "setAddress" -> {
                val address = call.argument<String>("address")
                val port = call.argument<Int>("port")

                if (address != null && port != null) {
                    observer.connection.address = InetSocketAddress(InetAddress.getByName(address), port)
                    result.success(null)
                } else {
                    result.error("UNAVAILABLE", "Address unable to be set.", null)
                }
            }
            "resetAddress" -> {
                observer.connection.address = null
                result.success(null)
            }
            "stopControl" -> {
                val control = observer.gamepad.control[call.argument<String>("control")]

                if (control != null) {
                    control.stop()
                    result.success(null)
                } else {
                    result.error("UNAVAILABLE", "Control unable to be stopped.", null)
                }
            }
            "blockControl" -> {
                val control = observer.gamepad.control[call.argument<String>("control")]

                if (control != null) {
                    control.block()
                    result.success(null)
                } else {
                    result.error("UNAVAILABLE", "Control unable to be blocked.", null)
                }
            }
            "resumeControl" -> {
                val control = observer.gamepad.control[call.argument<String>("control")]
                val safe = call.argument<Boolean>("safe")

                if (control != null && safe != null) {
                    result.success(control.resume(safe))
                } else {
                    result.error("UNAVAILABLE", "Control unable to be resumed.", null)
                }
            }
            "turnScreenOn" -> {
                observer.switchScreenBrightness(LayoutParams.BRIGHTNESS_OVERRIDE_NONE)
                result.success(true)
            }
            "turnScreenOff" -> {
                observer.switchScreenBrightness(LayoutParams.BRIGHTNESS_OVERRIDE_OFF)
                result.success(false)
            }
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        onAttach(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetach()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttach(binding)
    }

    override fun onDetachedFromActivity() {
        onDetach()
    }

    private fun onAttach(binding: ActivityPluginBinding) {
        observer.activity = binding.activity
        observer.lifecycle = (binding.lifecycle as HiddenLifecycleReference).lifecycle
        observer.lifecycle.addObserver(observer)
    }

    private fun onDetach() {
        observer.lifecycle.removeObserver(observer)
    }
}
