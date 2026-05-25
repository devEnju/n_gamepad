package com.marvinvogl.n_gamepad

import android.view.ActionMode
import android.view.InputDevice
import android.view.KeyEvent
import android.view.Menu
import android.view.MenuItem
import android.view.MotionEvent
import android.view.SearchEvent
import android.view.View
import android.view.View.OnKeyListener
import android.view.Window.Callback
import android.view.WindowManager
import android.view.accessibility.AccessibilityEvent

class KeyListener(
    private val observer: GamepadObserver,
    private val gamepad: Gamepad,
    private val connection: Connection,
) : OnKeyListener {
    companion object {
        val buffer = ControlBuffer(6, 2, 0b0100)
    }
    val dispatcher = KeyDispatcher()

    override fun onKey(v: View?, keyCode: Int, event: KeyEvent?): Boolean {
        if (event != null) {
            if (event.isFromSource(InputDevice.SOURCE_GAMEPAD)) {
                gamepad.button[keyCode]?.onEvent(event) ?: return false

                return connection.send(buffer)
            }
            if (event.isFromSource(InputDevice.SOURCE_DPAD)) {
                gamepad.dpad.onEvent(event)

                return connection.send(buffer)
            }
        }
        return false
    }

    inner class KeyDispatcher : Callback {
        override fun dispatchGenericMotionEvent(p0: MotionEvent?): Boolean {
            return observer.callback.dispatchGenericMotionEvent(p0)
        }

        override fun dispatchKeyEvent(p0: KeyEvent): Boolean {
            return onKey(null, p0.keyCode, p0) || observer.callback.dispatchKeyEvent(p0)
        }

        override fun dispatchKeyShortcutEvent(p0: KeyEvent?): Boolean {
            return observer.callback.dispatchKeyShortcutEvent(p0)
        }

        override fun dispatchPopulateAccessibilityEvent(p0: AccessibilityEvent?): Boolean {
            return observer.callback.dispatchPopulateAccessibilityEvent(p0)
        }

        override fun dispatchTouchEvent(p0: MotionEvent?): Boolean {
            return observer.callback.dispatchTouchEvent(p0)
        }

        override fun dispatchTrackballEvent(p0: MotionEvent?): Boolean {
            return observer.callback.dispatchTrackballEvent(p0)
        }

        override fun onActionModeFinished(p0: ActionMode?) {
            observer.callback.onActionModeFinished(p0)
        }

        override fun onActionModeStarted(p0: ActionMode?) {
            observer.callback.onActionModeStarted(p0)
        }

        override fun onAttachedToWindow() {
            observer.callback.onAttachedToWindow()
        }

        override fun onContentChanged() {
            observer.callback.onContentChanged()
        }

        override fun onCreatePanelMenu(p0: Int, p1: Menu): Boolean {
            return observer.callback.onCreatePanelMenu(p0, p1)
        }

        override fun onCreatePanelView(p0: Int): View? {
            return observer.callback.onCreatePanelView(p0)
        }

        override fun onDetachedFromWindow() {
            observer.callback.onDetachedFromWindow()
        }

        override fun onMenuItemSelected(p0: Int, p1: MenuItem): Boolean {
            return observer.callback.onMenuItemSelected(p0, p1)
        }

        override fun onMenuOpened(p0: Int, p1: Menu): Boolean {
            return observer.callback.onMenuOpened(p0, p1)
        }

        override fun onPanelClosed(p0: Int, p1: Menu) {
            observer.callback.onPanelClosed(p0, p1)
        }

        override fun onPreparePanel(p0: Int, p1: View?, p2: Menu): Boolean {
            return observer.callback.onPreparePanel(p0, p1, p2)
        }

        override fun onSearchRequested(): Boolean {
            return observer.callback.onSearchRequested()
        }

        override fun onSearchRequested(p0: SearchEvent?): Boolean {
            return observer.callback.onSearchRequested(p0)
        }

        override fun onWindowAttributesChanged(p0: WindowManager.LayoutParams?) {
            observer.callback.onWindowAttributesChanged(p0)
        }

        override fun onWindowFocusChanged(p0: Boolean) {
            observer.callback.onWindowFocusChanged(p0)
        }

        override fun onWindowStartingActionMode(p0: ActionMode.Callback?): ActionMode? {
            return observer.callback.onWindowStartingActionMode(p0)
        }

        override fun onWindowStartingActionMode(p0: ActionMode.Callback?, p1: Int): ActionMode? {
            return observer.callback.onWindowStartingActionMode(p0, p1)
        }
    }
}
