package com.yuuuzzzin.offoff_android.views.ui.schedule

import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.Window
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.viewModels
import com.yuuuzzzin.offoff_android.database.models.Shift
import com.yuuuzzzin.offoff_android.databinding.DialogShiftSettingBinding
import com.yuuuzzzin.offoff_android.viewmodel.ShiftSettingViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class ShiftSettingDialog : DialogFragment() {

    private var mBinding: DialogShiftSettingBinding? = null
    private val binding get() = mBinding!!
    private val viewModel: ShiftSettingViewModel by viewModels()
    private var id: Int? = null

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        mBinding = DialogShiftSettingBinding.inflate(inflater, container, false)

        dialog!!.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        dialog!!.window?.requestFeature(Window.FEATURE_NO_TITLE)

        if (arguments != null) {
            id = arguments?.getInt("id")!!
            //binding.etTitle.setText(arguments?.getString("title"))
            viewModel.initEtShift(arguments?.getString("title").toString())
            binding.tvStartTime.text = arguments?.getString("startTime")
            binding.tvEndTime.text = arguments?.getString("endTime")
            //binding.iconTitle.text = arguments?.getString("title").toString().substring(0, 1)
            binding.iconTitle.setTextColor(Color.parseColor(arguments?.getString("textColor")))
            binding.iconTitle.setBackgroundColor(
                Color.parseColor(arguments?.getString("backgroundColor"))
            )
        } else {
            viewModel.initEtShift()
        }

        initViewModel()

        binding.tvStartTime.setOnClickListener {
            binding.tpStart.visibility = View.VISIBLE
            if (binding.tpEnd.visibility == View.VISIBLE)
                binding.tpEnd.visibility = View.GONE
        }

        binding.tvEndTime.setOnClickListener {
            binding.tpEnd.visibility = View.VISIBLE
            if (binding.tpStart.visibility == View.VISIBLE)
                binding.tpStart.visibility = View.GONE
        }

        binding.tpStart.setOnTimeChangedListener { view, hourOfDay, minute ->
            binding.tvStartTime.text = (String.format("%02d:%02d", hourOfDay, minute))
        }

        binding.tpEnd.setOnTimeChangedListener { view, hourOfDay, minute ->
            binding.tvEndTime.text = (String.format("%02d:%02d", hourOfDay, minute))
        }

        viewModel.title.observe(viewLifecycleOwner, {
            Log.d("tag_observe", "값:" + it.toString())
        })

        binding.btCancel.setOnClickListener {
            dialog!!.dismiss()
        }

        binding.btConfirm.setOnClickListener {
            val shift = Shift(
                id = if(id != null) id else viewModel.getNextId(),
                title = binding.etTitle.text.toString(),
                textColor = "#000066",
                backgroundColor = "#3366FF",
                startTime = binding.tvStartTime.text.toString(),
                endTime = binding.tvEndTime.text.toString()
            )
            viewModel.insertShift(shift)
            dialog!!.dismiss()
        }

        return binding.root
    }

    private fun initViewModel() {
        //viewModel = ViewModelProvider(this).get(ShiftSettingViewModel::class.java)
        binding.lifecycleOwner = this
        binding.viewModel = viewModel
    }

    override fun onDestroyView() {
        mBinding = null
        super.onDestroyView()
    }
}