package com.yuuuzzzin.offoff_android.views.ui.member

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContract
import androidx.navigation.fragment.findNavController
import com.theartofdev.edmodo.cropper.CropImage
import com.theartofdev.edmodo.cropper.CropImageView
import com.yuuuzzzin.offoff_android.R
import com.yuuuzzzin.offoff_android.databinding.FragmentSignupStep3Binding
import com.yuuuzzzin.offoff_android.utils.Constants.toast
import com.yuuuzzzin.offoff_android.utils.ImageUtils.bitmapToString
import com.yuuuzzzin.offoff_android.utils.ImageUtils.uriToBitmap
import com.yuuuzzzin.offoff_android.utils.base.BaseSignupFragment
import dagger.hilt.android.AndroidEntryPoint


@AndroidEntryPoint
class SignupStep3Fragment :
    BaseSignupFragment<FragmentSignupStep3Binding>(R.layout.fragment_signup_step3) {

    private lateinit var cropActivityResultLauncher: ActivityResultLauncher<Any?>
    private var bitmap: Bitmap? = null
    private var profileImageSet: Boolean = false

    private val cropResultContract by lazy {
        object : ActivityResultContract<Any?, Uri?>() {
            override fun createIntent(context: Context, input: Any?): Intent {
                return CropImage
                    .activity()
                    .setCropShape(CropImageView.CropShape.RECTANGLE)
                    .getIntent(this@SignupStep3Fragment.requireContext())
            }

            override fun parseResult(resultCode: Int, intent: Intent?): Uri? {
                return CropImage.getActivityResult(intent)?.uri
            }
        }
    }

    override fun initView() {

        binding.ivPhoto.clipToOutline = true

        cropActivityResultLauncher = registerForActivityResult(cropResultContract) { uri ->
            uri?.path?.let {
                binding.ivPhoto.setImageURI(uri)
                bitmap = uriToBitmap(uri, requireActivity())
                // profileImageSet = true
            }
        }

        // step3 -> step2 이동
        binding.btBack.setOnClickListener {
            findNavController().navigate(R.id.action_signupStep3Fragment_to_signupStep2Fragment)
        }

        binding.btCamera.setOnClickListener {
            cropActivityResultLauncher.launch(null)
        }
    }

    override fun initViewModel() {
        binding.viewModel = signupViewModel

        signupViewModel.nickname.observe(viewLifecycleOwner, {
            if (!it.isNullOrBlank()) {
                signupViewModel.validateNickname()
            } else {
                binding.tvNickname.text = null
            }
        })

        signupViewModel.isNicknameVerified.observe(viewLifecycleOwner, {
            binding.tvNickname.text = it
        })

        signupViewModel.isNicknameError.observe(viewLifecycleOwner, {
            if (it.isNullOrEmpty()) {
                binding.tvNickname.text = null
            } else {
                binding.tvNickname.text = it
            }
        })

        // signup 액티비티 종료
        binding.btSignup.setOnClickListener {
            if (bitmap != null)
                signupViewModel.signup(bitmapToString(bitmap!!))
            else
                signupViewModel.signup(null)
            requireActivity().finish()
            requireContext().toast("가입이 완료되었습니다.")
        }
    }

//    private fun showProfileDialog() {
//
//        val array = arrayOf(
//            Constants.PROFILE_OPTION1,
//            Constants.PROFILE_OPTION2,
//            Constants.PROFILE_OPTION3
//        )
//        val builder = AlertDialog.Builder(mContext)
//
//        builder.setItems(array) { _, which ->
//            val selected = array[which]
//
//            try {
//                when (selected) {
//                    // 사진 찍기
//                    Constants.PROFILE_OPTION1 -> {
//                        true
//                    }
//                    // 앨범에서 가져오기
//                    Constants.PROFILE_OPTION2 -> {
//                        true
//                    }
//                    // 취소
//                    Constants.PROFILE_OPTION3 -> {
//                        true
//                    }
//                }
//
//            } catch (e: IllegalArgumentException) {
//
//            }
//        }
//
//        val dialog = builder.create()
//        dialog.show()
//    }
}