//
//  Constants.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/14.
//

import Foundation
import UIKit.UIColor
import SkyFloatingLabelTextField

public class Constants {
    static var mainColor: UIColor {
        return UIColor(named: "MainColor")!
    }
    
    static let ICON_SIZE = CGSize(width: 140, height: 140)
    
    static let USERID_MAXLENGTH = 20
    static let USERPW_MAXLENGTH = 16
    static let USERNAME_MAXLENGTH = 10
    static let USERID_RULE = "[A-Za-z0-9]{5,20}"
    static let USERPW_RULE = #"(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#\$%^&()_+=-]).{8,16}"#
    static let USERNAME_RULE = "[가-힣]{2,10}"
    static let USEREMAIL_RULE = #"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])"#
    static let USERBIRTH_RULE = #"(19[0-9][0-9]|20\d{2})년 (0[0-9]|1[0-2])월 (0[1-9]|[1-2][0-9]|3[0-1])일"#
    static let USERNICKNAME_RULE = "[가-힣A-Za-z0-9]{2,10}"
    
    static let PW_ERROR_MESSAGE = "비밀번호는 8-16자의 영문, 숫자, 기호만 사용 가능합니다."
    static let PWVERIFY_ERROR_MESSAGE = "비밀번호가 일치하지 않습니다."
    static let NAME_ERROR_MESSAGE = "올바른 형식의 이름이 아닙니다."
    static let EMAIL_ERROR_MESSAGE = "올바른 형식의 이메일이 아닙니다."
    static let BIRTH_ERROR_MESSAGE = "생년월일을 입력해주세요."
    
    static func isValidString(str: String?, regEx: String) -> Bool {
        guard let string = str else { return false }
        let prediction = NSPredicate(format: "SELF MATCHES %@", regEx)
        return prediction.evaluate(with: string)
    }
}

typealias TextField = SkyFloatingLabelTextFieldWithIcon

enum IDErrorMessage: String {
    case idEmpty = "아이디를 입력해주세요."
    case idDuplicated = "이미 사용중인 아이디입니다."
    case idNotFollowRule = "아이디는 최소 5-20자의 영문, 숫자만 사용 가능합니다."
}
