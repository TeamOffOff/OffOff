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
import com.yuuuzzzin.offoff_android.views.ui.LoadingDialog
import dagger.hilt.android.AndroidEntryPoint


@AndroidEntryPoint
class SignupStep3Fragment :
    BaseSignupFragment<FragmentSignupStep3Binding>(R.layout.fragment_signup_step3) {

    private lateinit var cropActivityResultLauncher: ActivityResultLauncher<Any?>
    private lateinit var loadingDialog: LoadingDialog
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

        loadingDialog = LoadingDialog(this@SignupStep3Fragment.requireContext())

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

        signupViewModel.loading.observe(binding.lifecycleOwner!!, { event ->
            event.getContentIfNotHandled()?.let {
                if (it) {
                    loadingDialog.show()
                } else {
                    loadingDialog.dismiss()
                }
            }
        })

        signupViewModel.step3Success.observe(binding.lifecycleOwner!!, {
            loadingDialog.dismiss()
            requireActivity().finish()
            requireContext().toast("가입이 완료되었습니다.")
        })

        // signup 액티비티 종료
        binding.btSignup.setOnClickListener {
            if (bitmap != null)
                signupViewModel.signup(bitmapToString(bitmap!!))
            else
                signupViewModel.signup(null)
        }

    }

}