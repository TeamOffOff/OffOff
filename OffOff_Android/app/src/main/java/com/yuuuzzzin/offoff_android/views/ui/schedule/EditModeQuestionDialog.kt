package com.yuuuzzzin.offoff_android.views.ui.schedule

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.yuuuzzzin.offoff_android.databinding.DialogEditModeQuestionBinding

class EditModeQuestionDialog : BottomSheetDialogFragment() {
    private var mBinding: DialogEditModeQuestionBinding? = null
    private val binding get() = mBinding!!
    private lateinit var mDialogResult:DialogReault

    interface DialogReault{
        fun finish(result: Boolean)
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        mBinding = DialogEditModeQuestionBinding.inflate(inflater, container, false)

        binding.btOk.setOnClickListener {
            mDialogResult.finish(true)
            dialog!!.dismiss()

        }

        binding.btCancel.setOnClickListener {
            mDialogResult.finish(false)
            dialog!!.dismiss()
        }

        return binding.root
    }

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
    }

    fun setDialogResult(dialogResult: DialogReault) {
        mDialogResult = dialogResult
    }
}