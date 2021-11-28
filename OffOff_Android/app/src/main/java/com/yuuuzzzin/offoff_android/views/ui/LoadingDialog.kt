package com.yuuuzzzin.offoff_android.views.ui

import android.annotation.SuppressLint
import android.app.AlertDialog
import android.app.Dialog
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.animation.AnimationUtils
import android.widget.ImageView
import androidx.fragment.app.DialogFragment
import com.yuuuzzzin.offoff_android.R

class LoadingDialog(context: Context) : Dialog(context) {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.dialog_loading)
        setCancelable(false)
        window!!.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))

        val iv: ImageView = findViewById(R.id.iv_loading)
        val rotateAnimation = AnimationUtils.loadAnimation(
            context,
            R.anim.animation_loading
        )

        iv.startAnimation(rotateAnimation)
    }
}

//class LoadingDialog : DialogFragment() {
//
//    @SuppressLint("InflateParams")
//    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
//        return activity?.let {
//            val builder = AlertDialog.Builder(it)
//            val inflater = requireActivity().layoutInflater;
//
//            builder.setView(inflater.inflate(R.layout.dialog_loading, null))
//            builder.create()
//
//        } ?: throw IllegalStateException("Activity cannot be null")
//    }
//}

//    override fun onCreateDialog(savedInstanceState: Bundle): Dialog {
//        return activity?.let {
//            val builder = AlertDialog.Builder(it)
//            val inflater = requireActivity().layoutInflater;
//
//            builder.setView(inflater.inflate(R.layout.dialog_loading, null))
//            builder.create()
//
//        } ?: throw IllegalStateException("Activity cannot be null")
//    }
//}