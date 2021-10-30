package com.yuuuzzzin.offoff_android.utils

import android.app.AlertDialog
import android.content.Context
import android.content.DialogInterface
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

object DialogUtils {

    fun showYesNoDialog(
        context: Context,
        message: String,
        onPositiveClick: DialogInterface.OnClickListener,
        onNegativeClick: DialogInterface.OnClickListener
    ) {
        AlertDialog.Builder(context).apply {
            setMessage(message)
            setPositiveButton("예", onPositiveClick)
            setNegativeButton("아니오", onNegativeClick)
            show()
        }
    }

    fun showYesDialog(context: Context, message: String) {
        AlertDialog.Builder(context).apply {
            setMessage(message)
            setNegativeButton("예", null)
            show()
        }
    }

    fun showAutoCloseDialog(context: Context, message: String) {
        AlertDialog.Builder(context).create().apply {
            setMessage(message)
            CoroutineScope(Dispatchers.Main).launch {
                show()
                delay(500)
                dismiss()
            }
        }
    }
}