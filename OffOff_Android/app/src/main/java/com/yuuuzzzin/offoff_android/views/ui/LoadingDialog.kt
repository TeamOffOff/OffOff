package com.yuuuzzzin.offoff_android.views.ui

import android.app.Dialog
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.AnimationDrawable
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.widget.ImageView
import com.yuuuzzzin.offoff_android.R

class LoadingDialog(context: Context) : Dialog(context){

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.dialog_loading)

//        val imageView : ImageView = findViewById(R.id.iv_loading)
//
//        val animation: AnimationDrawable = imageView.background as AnimationDrawable
//        animation.start()

        setCancelable(false)
        window!!.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
    }
}