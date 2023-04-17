package com.marvinvogl.n_gamepad_example

import android.annotation.SuppressLint
import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private lateinit var view: View

    @SuppressLint("ResourceType")
    override fun onStart() {
        super.onStart()

        view = window.findViewById<ViewGroup>(1).getChildAt(0)
    }

    override fun dispatchKeyEvent(event: KeyEvent?): Boolean {
        return view.dispatchKeyEvent(event)
    }
}
