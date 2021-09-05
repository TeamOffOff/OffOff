package com.yuuuzzzin.offoff_android.views.ui.schedule

import android.os.Bundle
import android.util.Log
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.Observer
import com.yuuuzzzin.offoff_android.database.models.Shift
import com.yuuuzzzin.offoff_android.databinding.ActivityShiftSettingBinding
import com.yuuuzzzin.offoff_android.viewmodel.ScheduleViewModel
import com.yuuuzzzin.offoff_android.views.adapter.ShiftListAdapter
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class ShiftSettingActivity : AppCompatActivity() {

    private lateinit var binding: ActivityShiftSettingBinding
    private lateinit var shiftlistAdapter: ShiftListAdapter
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
            viewModel.insertShift(Shift(5, "E", "black", "white", "14:30", "23:00"))
//            val dialog = ScheduleTypeSettingDialog()
//            dialog.show(supportFragmentManager, "custom_dialog")
        }
    }

    private fun initViewModel() {
        binding.viewModel = viewModel

        shiftlistAdapter = ShiftListAdapter()
        binding.rvScheduleType.adapter = shiftlistAdapter

//        viewModel.getAllShifts()
//            .observe(this, Observer {
//                it?.let {
//                    shiftlistAdapter.updateList(it)
//                }
//            })

        viewModel.shiftList.observe(this, Observer { shiftList ->
            shiftList?.let { shiftlistAdapter.updateList(it) }
            Log.d("tag_realm_test", "shiftList변화 감지")
        })

    }
}

