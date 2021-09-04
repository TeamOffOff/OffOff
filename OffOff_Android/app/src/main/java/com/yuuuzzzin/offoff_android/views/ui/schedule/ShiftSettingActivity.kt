package com.yuuuzzzin.offoff_android.views.ui.schedule

import android.os.Bundle
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import com.yuuuzzzin.offoff_android.databinding.ActivityShiftSettingBinding
import com.yuuuzzzin.offoff_android.viewmodel.ScheduleViewModel
import com.yuuuzzzin.offoff_android.views.adapter.ScheduleTypeSettingListAdapter
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class ShiftSettingActivity : AppCompatActivity() {

    private lateinit var binding: ActivityShiftSettingBinding
    private lateinit var scheduleTypeSettingListAdapter: ScheduleTypeSettingListAdapter
    private val viewModel: ScheduleViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityShiftSettingBinding.inflate(layoutInflater)

        initRV()
        initView()
        initViewModel()

        setContentView(binding.root)
    }

    private fun initRV() {

    }

    private fun initView() {
        binding.btAdd.setOnClickListener {
            val dialog = ScheduleTypeSettingDialog()
            dialog.show(supportFragmentManager, "custom_dialog")
        }
    }

    private fun initViewModel() {
        binding.viewModel = viewModel

        scheduleTypeSettingListAdapter = ScheduleTypeSettingListAdapter()
        binding.rvScheduleType.adapter =scheduleTypeSettingListAdapter

//        scheduleTypeSettingListAdapter.shiftList.addAll(
//            viewModel.allShifts
//        )
    }
}

