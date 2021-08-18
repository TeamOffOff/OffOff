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

        splashViewModel.autoLogin.observe(this, {
            if (it) {
                Intent(
                    baseContext,
                    MainActivity::class.java
                ).run {
                    flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
                    startActivity(this)
                }
                finish()
            }
        })

        splashViewModel.moveLogin.observe(this, {
            if (it) {
                Intent(
                    baseContext,
                    LoginActivity::class.java
                ).run {
                    flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
                    startActivity(this)
                    finish()
                }
            }
        })
    }
}