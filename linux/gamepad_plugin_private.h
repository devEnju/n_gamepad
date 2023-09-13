#include <flutter_linux/flutter_linux.h>

#include "include/n_gamepad/gamepad_plugin.h"

// This file exposes some plugin internals for unit testing. See
// https://github.com/flutter/flutter/issues/88724 for current limitations
// in the unit-testable API.

// Handles the getPlatformVersion method call.
FlMethodResponse *set_address(FlMethodCall* method_call);
FlMethodResponse *reset_address(FlMethodCall* method_call);
