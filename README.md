# n Gamepad
A Flutter plugin to listen to game controller inputs.

## Usage
Add the following lines of code to your `FlutterActivity` in order to override Android's standard input settings for gamepads:

```kotlin
class MainActivity : FlutterActivity() {
    private lateinit var view: View

    override fun onStart() {
        super.onStart()

        view = window.findViewById<ViewGroup>(1).getChildAt(0)
    }

    override fun dispatchKeyEvent(event: KeyEvent?): Boolean {
        return view.dispatchKeyEvent(event)
    }
}
```

This configuration step is necessary for the proper functioning of the plugin.

For comprehensive documentation on the network capabilities, please refer to the [nx Gamepad](https://github.com/devEnju/nx_gamepad) repository.
