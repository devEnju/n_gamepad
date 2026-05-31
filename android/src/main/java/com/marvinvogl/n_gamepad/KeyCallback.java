package com.marvinvogl.n_gamepad;

import androidx.annotation.Keep;

@Keep
public interface KeyCallback {
  void onKeyEvent(int keyCode, int action);
}
