package com.yuuuzzzin.offoff_android.views.ui.schedule

import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.PopupMenu
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import com.yuuuzzzin.offoff_android.R
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
    private val dialog = ShiftSettingDialog()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityShiftSettingBinding.inflate(layoutInflater)

        initRV()
        initView()
        initViewModel()

        setContentView(binding.root)
    }

    private fun initRV() {
        /* click listener 재정의 */
        shiftlistAdapter = ShiftListAdapter()
        binding.rvScheduleType.adapter = shiftlistAdapter

        shiftlistAdapter.setOnShiftMenuClickListener(object :
            ShiftListAdapter.OnShiftMenuClickListener {
            override fun onShiftMenuClick(view: View, shift: Shift) {

                var popupMenu = PopupMenu(applicationContext, view)

                menuInflater.inflate(R.menu.menu_shift, popupMenu.menu)
                popupMenu.show()
                popupMenu.setOnMenuItemClickListener { menu ->
                    when (menu.itemId) {
                        R.id.action_edit -> {
                            val bundle = Bundle()
                            bundle.putInt("id", shift.id!!)
                            bundle.putString("title", shift.title)
                            bundle.putString("textColor", shift.textColor)
                            bundle.putString("backgroundColor", shift.backgroundColor)
                            bundle.putString("startTime", shift.startTime)
                            bundle.putString("endTime", shift.endTime)
                            dialog.arguments = bundle
                            dialog.show(supportFragmentManager, "custom_dialog")
                            true
                        }
                        R.id.action_delete -> {
                            viewModel.deleteShift(shift.id!!)
                            true
                        }
                    }
                    false
                }
            }
        })
    }

    private fun initView() {
        binding.btAdd.setOnClickListener {
            //viewModel.insertShift(Shift(5, "E", "black", "white", "14:30", "23:00"))
            dialog.show(supportFragmentManager, "shift_setting_dialog")
        }
    }

    private fun initViewModel() {
        binding.lifecycleOwner = this
        binding.viewModel = viewModel

        viewModel.shiftList.observe(this, { shiftList ->
            shiftList?.let { shiftlistAdapter.updateList(it) }
            Log.d("tag_realm_test", "shiftList 변화 감지")
        })
    }
}

