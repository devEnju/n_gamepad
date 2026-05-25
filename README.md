A Flutter plugin to listen to game controller inputs.

## Features

- Allows listening to controller inputs from gamepad accessories on Android phones
- Provides a framework to implement multi-device functionality, as demonstrated in [this video](https://youtu.be/yzNlsgG5A7c)

## Getting started

Add the package to your `pubspec.yaml` and the plugin registers itself automatically via Flutter's plugin mechanism. No additional setup is required.

> **Android:** This plugin listens for controller key events by wrapping the activity's `Window.Callback`. It works alongside other plugins as long as they forward callbacks correctly and do not consume the relevant key events.

## Usage

Access the `Gamepad.instance` and assign handlers to a specific `Button`, the dpad, joysticks, and triggers. To reset individual input handlers, call the same method without specifying any functions.

```dart
// Sets onPress and onRelease handler for the A button
Gamepad.instance.assignButtonListener(Button.a, onPress: (event) {}, onRelease: (event) {});
// Resets onPress and sets onRelease handler for the B button
Gamepad.instance.assignButtonListener(Button.b, onRelease: (event) {});
// Sets onUse handler for the right joystick
Gamepad.instance.assignJoystickListener(Hand.right, onUse: (event) {});
// Resets onPress and onRelease handler of B button
Gamepad.instance.assignButtonListener(Button.b);
// Resets handlers for all input controls
Gamepad.instance.resetControls();
```

## Additional information

For comprehensive documentation on the network capabilities, please refer to the [nx Gamepad](https://github.com/devEnju/nx_gamepad) repository.
