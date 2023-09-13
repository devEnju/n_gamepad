//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <n_gamepad/gamepad_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) n_gamepad_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "GamepadPlugin");
  gamepad_plugin_register_with_registrar(n_gamepad_registrar);
}
