package com.marvinvogl.n_gamepad_example

import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private lateinit var view: View

    override fun onStart() {
        super.onStart()

        view = window.findViewById<ViewGroup>(FLUTTER_VIEW_ID).getChildAt(0)
    }

    override fun dispatchKeyEvent(event: KeyEvent?): Boolean {
        return view.dispatchKeyEvent(event)
    }
}
