# n Gamepad

A Flutter plugin to listen to game controller inputs.

## Features

- Allows listening to controller inputs from gamepad accessories on Android phones
- Provides a framework to implement multi-device functionality, as demonstrated in [this video](https://youtu.be/yzNlsgG5A7c)

## Getting started

Add the following lines of code to your `FlutterActivity` in order to override Android's standard input settings for gamepads:

```kotlin
class MainActivity : FlutterActivity() {
    private lateinit var view: View

    override fun onStart() {
        super.onStart()

        view = window.findViewById<ViewGroup>(FLUTTER_VIEW_ID).getChildAt(0)
    }

    override fun dispatchKeyEvent(event: KeyEvent?): Boolean {
        return view.dispatchKeyEvent(event)
    }
}
```

This configuration step is necessary for the proper functioning of the plugin on the Android platform.

## Usage

Access the `Gamepad.instance` and assign handlers to a specific `Button`, the dpad, joysticks, and triggers. To reset individual input handlers, call the same method without specifying any functions.

```dart
// Sets onPress and onRelease handler for the A button
Gamepad.instance.assignButtonListener(Button.a, onPress: () {}, onRelease: () {});
// Resets onPress and sets onRelease handler for the B button
Gamepad.instance.assignButtonListener(Button.b, onRelease: () {});
// Sets onEvent handler for the right joystick
Gamepad.instance.assignJoystickListener(Hand.right, onEvent: (event) {});
// Resets onPress and onRelease handler of B button
Gamepad.instance.assignButtonListener(Button.b);
// Resets handlers for all input controls
Gamepad.instance.resetControls();
```

## Additional information

For comprehensive documentation on the network capabilities, please refer to the [nx Gamepad](https://github.com/devEnju/nx_gamepad) repository.
