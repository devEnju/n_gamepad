package com.marvinvogl.n_gamepad;

import androidx.annotation.Keep;

@Keep
public interface KeyEventListener {
  void onKeyEvent(int keyCode, int action);
}
