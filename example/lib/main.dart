import 'package:flutter/material.dart';

import 'package:n_gamepad/n_gamepad.dart';

void main() async {
  await Connection.instantiate();

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
  bool _dpad = false;
  bool _buttonA = false;
  bool _buttonB = false;
  bool _buttonX = false;
  bool _buttonY = false;

  String _text = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            Gamepad.instance.resetControls();
            setState(() {
              _dpad = false;
              _buttonA = false;
              _buttonB = false;
              _buttonX = false;
              _buttonY = false;
            });
          },
        ),
        title: const Text('Gamepad Plugin Example'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _buttonA = _buttonA
                ? Gamepad.instance.assignButtonListener(Button.a)
                : Gamepad.instance.assignButtonListener(Button.a,
                    onPress: () =>
                        setState(() => _text = '[ButtonEvent (a: pressed)]'),
                    onRelease: () =>
                        setState(() => _text = '[ButtonEvent (a: released)]'))),
            icon: Text(
              'A',
              style: TextStyle(fontWeight: _buttonA ? FontWeight.bold : null),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _buttonB = _buttonB
                ? Gamepad.instance.assignButtonListener(Button.b)
                : Gamepad.instance.assignButtonListener(Button.b,
                    onPress: () =>
                        setState(() => _text = '[ButtonEvent (b: pressed)]'),
                    onRelease: () =>
                        setState(() => _text = '[ButtonEvent (b: released)]'))),
            icon: Text(
              'B',
              style: TextStyle(fontWeight: _buttonB ? FontWeight.bold : null),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _buttonX = _buttonX
                ? Gamepad.instance.assignButtonListener(Button.x)
                : Gamepad.instance.assignButtonListener(Button.x,
                    onPress: () =>
                        setState(() => _text = '[ButtonEvent (x: pressed)]'),
                    onRelease: () =>
                        setState(() => _text = '[ButtonEvent (x: released)]'))),
            icon: Text(
              'X',
              style: TextStyle(fontWeight: _buttonX ? FontWeight.bold : null),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _buttonY = _buttonY
                ? Gamepad.instance.assignButtonListener(Button.y)
                : Gamepad.instance.assignButtonListener(Button.y,
                    onPress: () =>
                        setState(() => _text = '[ButtonEvent (y: pressed)]'),
                    onRelease: () =>
                        setState(() => _text = '[ButtonEvent (y: released)]'))),
            icon: Text(
              'Y',
              style: TextStyle(fontWeight: _buttonY ? FontWeight.bold : null),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Last button state:'),
            Text(
              _text,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _dpad = _dpad
            ? Gamepad.instance.assignDpadListener()
            : Gamepad.instance.assignDpadListener(
                onEvent: (event) => setState(() => _text = '$event'))),
        child: Icon(_dpad ? Icons.gamepad : Icons.gamepad_outlined),
      ),
    );
  }
}
