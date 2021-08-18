package com.yuuuzzzin.offoff_android.service.repository

import com.yuuuzzzin.offoff_android.service.api.MemberService
import com.yuuuzzzin.offoff_android.service.models.LoginInfo
import com.yuuuzzzin.offoff_android.service.models.User
import javax.inject.Inject

/* 로그인, 회원가입 Repository */

class MemberRepository

@Inject
constructor(private val memberService: MemberService) {

    suspend fun login(loginInfo: LoginInfo) =
        memberService.login(loginInfo)

    suspend fun signup(user: User) =
        memberService.signup(user)

    suspend fun checkId(id: String) =
        memberService.checkId(id)

    suspend fun checkNickname(nickname: String) =
        memberService.checkNickname(nickname)

    suspend fun checkEmail(email: String) =
        memberService.checkEmail(email)

    suspend fun getUserInfo(auth: String) =
        memberService.getUserInfo(auth)
}
