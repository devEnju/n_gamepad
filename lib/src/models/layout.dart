import 'package:flutter/material.dart';

class LayoutData {
  const LayoutData(
    this.widget, {
    this.backgroundColor,
    this.screenTimeout = const ScreenTimeout(
      onInteraction: Duration(seconds: 10),
      onStateChange: Duration(seconds: 5),
    ),
  });

  final Widget widget;
  final Color? backgroundColor;
  final ScreenTimeout? screenTimeout;
}

class ScreenTimeout {
  const ScreenTimeout({
    required this.onInteraction,
    this.onStateChange,
    this.onStateUpdate,
  });

  final Duration onInteraction;
  final Duration? onStateChange;
  final Duration? onStateUpdate;
}
