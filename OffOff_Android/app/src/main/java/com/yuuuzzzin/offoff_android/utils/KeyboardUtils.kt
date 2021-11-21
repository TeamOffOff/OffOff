package com.yuuuzzzin.offoff_android.utils

import android.app.Activity
import android.content.Context
import android.graphics.Rect
import android.view.View
import android.view.ViewTreeObserver
import android.view.Window
import android.view.inputmethod.InputMethodManager
import androidx.fragment.app.Fragment

object KeyboardUtils {
    fun hideKeyboard(context: Context?, view: View?) {
        if (context == null || view == null) return
        val imm = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.hideSoftInputFromWindow(view.windowToken, 0)
    }

    fun Fragment.hideKeyboard() = activity?.hideKeyboard()

    fun Activity.hideKeyboard() = KeyboardUtils.hideKeyboard(this, currentFocus)

    fun showKeyboard(context: Context) {
        val inputMethodManager = context.getSystemService(
            Context.INPUT_METHOD_SERVICE
        ) as InputMethodManager
        inputMethodManager.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0)
    }

    fun View.requestFocusAndShowKeyboard(context: Context) {
        post {
            requestFocus()
            showKeyboard(context)
        }
    }

    class KeyboardVisibilityUtils(
        private val window: Window,
        private val onShowKeyboard: (() -> Unit)? = null,
        private val onHideKeyboard: (() -> Unit)? = null
    ) {

        private val MIN_KEYBOARD_HEIGHT_PX = 150

        private val windowVisibleDisplayFrame = Rect()
        private var lastVisibleDecorViewHeight: Int = 0


        private val onGlobalLayoutListener = ViewTreeObserver.OnGlobalLayoutListener {
            window.decorView.getWindowVisibleDisplayFrame(windowVisibleDisplayFrame)
            val visibleDecorViewHeight = windowVisibleDisplayFrame.height()

            if (lastVisibleDecorViewHeight != 0) {
                if (lastVisibleDecorViewHeight > visibleDecorViewHeight + MIN_KEYBOARD_HEIGHT_PX) {
                    onShowKeyboard?.invoke()
                } else if (lastVisibleDecorViewHeight + MIN_KEYBOARD_HEIGHT_PX < visibleDecorViewHeight) {
                    onHideKeyboard?.invoke()
                }
            }
            lastVisibleDecorViewHeight = visibleDecorViewHeight
        }

        init {
            window.decorView.viewTreeObserver.addOnGlobalLayoutListener(onGlobalLayoutListener)
        }

        fun detachKeyboardListeners() {
            window.decorView.viewTreeObserver.removeOnGlobalLayoutListener(onGlobalLayoutListener)
        }
    }
}

