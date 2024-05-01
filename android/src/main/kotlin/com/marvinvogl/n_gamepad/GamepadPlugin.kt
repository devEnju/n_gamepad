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
        private const val BUTTON = "com.marvinvogl.n_gamepad/button"
        private const val DPAD = "com.marvinvogl.n_gamepad/dpad"
        private const val JOYSTICK = "com.marvinvogl.n_gamepad/joystick"
        private const val TRIGGER = "com.marvinvogl.n_gamepad/trigger"
    }
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var buttonChannel: EventChannel
    private lateinit var dpadChannel: EventChannel
    private lateinit var joystickChannel: EventChannel
    private lateinit var triggerChannel: EventChannel

    private val observer = GamepadObserver()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD)
        buttonChannel = EventChannel(flutterPluginBinding.binaryMessenger, BUTTON)
        dpadChannel = EventChannel(flutterPluginBinding.binaryMessenger, DPAD)
        joystickChannel = EventChannel(flutterPluginBinding.binaryMessenger, JOYSTICK)
        triggerChannel = EventChannel(flutterPluginBinding.binaryMessenger, TRIGGER)

        channel.setMethodCallHandler(this)
        buttonChannel.setStreamHandler(Handler.button)
        dpadChannel.setStreamHandler(Handler.dpad)
        joystickChannel.setStreamHandler(Handler.joystick)
        triggerChannel.setStreamHandler(Handler.trigger)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        buttonChannel.setStreamHandler(null)
        dpadChannel.setStreamHandler(null)
        joystickChannel.setStreamHandler(null)
        triggerChannel.setStreamHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "set_address" -> {
                val address = call.argument<String>("address")
                val port = call.argument<Int>("port")

                if (address != null && port != null) {
                    observer.connection.address = InetSocketAddress(InetAddress.getByName(address), port)
                    result.success(null)
                } else {
                    result.error("UNAVAILABLE", "Address unable to be set.", null)
                }
            }
            "reset_address" -> {
                observer.connection.address = null
                result.success(null)
            }
            "stop_control" -> {
                val control = observer.gamepad.control[call.argument<String>("control")]

                if (control != null) {
                    control.stop()
                    result.success(null)
                } else {
                    result.error("UNAVAILABLE", "Control unable to be stopped.", null)
                }
            }
            "block_control" -> {
                val control = observer.gamepad.control[call.argument<String>("control")]

                if (control != null) {
                    control.block()
                    result.success(null)
                } else {
                    result.error("UNAVAILABLE", "Control unable to be blocked.", null)
                }
            }
            "resume_control" -> {
                val control = observer.gamepad.control[call.argument<String>("control")]
                val safe = call.argument<Boolean>("safe")

                if (control != null && safe != null) {
                    result.success(control.resume(safe))
                } else {
                    result.error("UNAVAILABLE", "Control unable to be resumed.", null)
                }
            }
            "turn_screen_on" -> {
                observer.switchScreenBrightness(LayoutParams.BRIGHTNESS_OVERRIDE_NONE)
                result.success(true)
            }
            "turn_screen_off" -> {
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
