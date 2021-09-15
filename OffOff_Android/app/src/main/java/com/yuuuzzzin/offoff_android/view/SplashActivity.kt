package com.yuuuzzzin.offoff_android.view

import android.content.Intent
import android.os.Bundle
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import com.yuuuzzzin.offoff_android.MainActivity
import com.yuuuzzzin.offoff_android.view.ui.member.LoginActivity
import com.yuuuzzzin.offoff_android.viewmodel.SplashViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class SplashActivity : AppCompatActivity() {
    private val splashViewModel: SplashViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 토큰이 저장된 자동로그인 상태라면 메인 화면으로 이동
        splashViewModel.autoLogin.observe(this, {
            if (it) {
                val intent = Intent(this@SplashActivity, MainActivity::class.java)
                startActivity(intent)
            }
        })

        // 토큰이 없거나 유효하지 않은 상태라면 로그인 화면으로 이동
        splashViewModel.moveLogin.observe(this, {
            if (it) {
                val intent = Intent(this@SplashActivity, LoginActivity::class.java)
                startActivity(intent)
            }
        })
    }
}