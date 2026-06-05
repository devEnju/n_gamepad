package com.marvinvogl.n_gamepad;

import androidx.annotation.Keep;

@Keep
public interface KeyCallable {
  void callback(int id, int keyCode, int action);
}
