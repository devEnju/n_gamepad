import 'package:flutter/material.dart';

import 'package:n_gamepad/n_gamepad.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final map = <Enum, bool>{
    Button.a: false,
    Button.b: false,
    Button.x: false,
    Button.y: false,
    Control.dpad: false,
  };

  String text = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: resetGamepadListeners,
        ),
        title: const Text('Gamepad Plugin Example'),
        actions: [
          for (var element in map.keys)
            if (element is Button)
              IconButton(
                onPressed: () => toggleGamepadButtonListener(element),
                icon: Text(
                  element.name.toUpperCase(),
                  style: TextStyle(
                    fontWeight: map[element] == true ? FontWeight.bold : null,
                  ),
                ),
              ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Last button state:'),
            Text(text, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleGamepadDpadListener,
        child: Icon(
          map[Control.dpad] == true ? Icons.gamepad : Icons.gamepad_outlined,
        ),
      ),
    );
  }

  void resetGamepadListeners() {
    Gamepad.instance.resetControls();

    setState(() {
      for (var element in map.keys) {
        map[element] = false;
      }
    });
  }

  void toggleGamepadButtonListener(Button button) {
    setState(() {
      if (map[button] == true) {
        map[button] = Gamepad.instance.assignButtonListener(button);
      } else {
        map[button] = Gamepad.instance.assignButtonListener(
          button,
          onPress: onGamepadButtonEvent,
          onRelease: onGamepadButtonEvent,
        );
      }
    });
  }

  void onGamepadButtonEvent(ButtonEvent event) {
    setState(() => text = '$event');
  }

  void toggleGamepadDpadListener() {
    setState(() {
      if (map[Control.dpad] == true) {
        map[Control.dpad] = Gamepad.instance.assignDpadListener();
      } else {
        map[Control.dpad] = Gamepad.instance.assignDpadListener(
          onUse: onGamepadDpadEvent,
        );
      }
    });
  }

  void onGamepadDpadEvent(DpadEvent event) {
    setState(() => text = '$event');
  }
}
