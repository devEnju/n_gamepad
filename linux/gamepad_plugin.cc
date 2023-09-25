#include "include/n_gamepad/gamepad_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#include "gamepad_plugin_private.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

#define GAMEPAD_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), gamepad_plugin_get_type(), \
                              GamepadPlugin))

struct _GamepadPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(GamepadPlugin, gamepad_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void gamepad_plugin_handle_method_call(
    GamepadPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "setAddress") == 0) {
    response = set_address(method_call);
  } else if (strcmp(method, "resetAddress") == 0) {
    response = reset_address(method_call);
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

FlMethodResponse* set_address(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  FlValue *address_val = fl_value_lookup_string(args, "address");
  FlValue *port_val = fl_value_lookup_string(args, "port");

  if (address_val != nullptr && fl_value_get_type(address_val) == FL_VALUE_TYPE_STRING && port_val != nullptr && fl_value_get_type(port_val) == FL_VALUE_TYPE_INT) {
    const gchar *address = fl_value_get_string(address_val);
    const int64_t port = fl_value_get_int(port_val);

    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    struct sockaddr_in servaddr;

    if (sockfd < 0) {
      g_warning("Failed to initialize the socket.");
    }

    std::memset(&servaddr, 0, sizeof(servaddr));

    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(port);
    servaddr.sin_addr.s_addr = inet_addr(address);

    // sendto(sockfd, buffer, strlen(buffer), 0, (const struct sockaddr *)&servaddr, sizeof(servaddr));

    return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  }
  return FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
}

FlMethodResponse* reset_address(FlMethodCall* method_call) {
  return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
}

static void gamepad_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(gamepad_plugin_parent_class)->dispose(object);
}

static void gamepad_plugin_class_init(GamepadPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = gamepad_plugin_dispose;
}

static void gamepad_plugin_init(GamepadPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  GamepadPlugin* plugin = GAMEPAD_PLUGIN(user_data);
  gamepad_plugin_handle_method_call(plugin, method_call);
}

void gamepad_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  GamepadPlugin* plugin = GAMEPAD_PLUGIN(
      g_object_new(gamepad_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "com.marvinvogl.n_gamepad/method",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
