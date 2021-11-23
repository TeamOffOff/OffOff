package com.yuuuzzzin.offoff_android.utils

import android.content.Context
import android.graphics.drawable.Drawable
import android.text.Editable
import android.text.TextWatcher
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.View
import androidx.appcompat.widget.AppCompatEditText
import androidx.core.content.ContextCompat
import androidx.core.graphics.drawable.DrawableCompat
import com.yuuuzzzin.offoff_android.R

class ClearEditText : AppCompatEditText, TextWatcher, View.OnTouchListener, View.OnFocusChangeListener {

    private var clearDrawable: Drawable? = null
    private var startDrawable: Drawable? = null
    private var onFocusChange: OnFocusChangeListener? = null
    private var onTouchListener: OnTouchListener? = null

    constructor(context: Context) : super(context) {
        init()
    }

    constructor(context: Context, attrs: AttributeSet) : super(context, attrs) {
        init()
    }

    constructor(context: Context, attrs: AttributeSet, defStyleAttr: Int) : super(context, attrs, defStyleAttr) {
        init()
    }

    override fun setOnFocusChangeListener(onFocusChangeListener: OnFocusChangeListener) {
        this.onFocusChange = onFocusChangeListener
    }

    override fun setOnTouchListener(onTouchListener: OnTouchListener) {
        this.onTouchListener = onTouchListener
    }

    private fun init() {
        val btClear = ContextCompat.getDrawable(context, R.drawable.ic_button_x)
        clearDrawable = DrawableCompat.wrap(btClear!!)
        clearDrawable!!.setBounds(0, 0, clearDrawable!!.intrinsicWidth, clearDrawable!!.intrinsicHeight)
//
//        val ivSearch = ContextCompat.getDrawable(context, R.drawable.ic_search)
//        startDrawable = DrawableCompat.wrap(ivSearch!!)
//        startDrawable!!.setTint(getColor(R.color.green))

        setClearIconVisible(false)

        super.setOnTouchListener(this)
        super.setOnFocusChangeListener(this)
        addTextChangedListener(this)
    }


    override fun onFocusChange(view: View, hasFocus: Boolean) {
        if (hasFocus) {
            setClearIconVisible(text!!.isNotEmpty())
        } else {
            setClearIconVisible(false)
        }

        if (onFocusChange != null) {
            onFocusChange!!.onFocusChange(view, hasFocus)
        }
    }


    override fun onTouch(view: View, motionEvent: MotionEvent): Boolean {
        val x = motionEvent.x.toInt()
        if (clearDrawable!!.isVisible && x > width - paddingRight - clearDrawable!!.intrinsicWidth) {
            if (motionEvent.action == MotionEvent.ACTION_UP) {
                error = null
                text = null
            }
            return true
        }

        return if (onTouchListener != null) {
            onTouchListener!!.onTouch(view, motionEvent)
        } else {
            false
        }

    }

    override fun onTextChanged(s: CharSequence, start: Int, before: Int, count: Int) {
        if (isFocused) {
            setClearIconVisible(s.isNotEmpty())
        }
    }

    override fun beforeTextChanged(s: CharSequence, start: Int, count: Int, after: Int) {}

    override fun afterTextChanged(s: Editable) {}

    private fun setClearIconVisible(visible: Boolean) {
        clearDrawable!!.setVisible(visible, false)
        setCompoundDrawables(null, null, if (visible) clearDrawable else null, null)
    }
}