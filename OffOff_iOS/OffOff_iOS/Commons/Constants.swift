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
    static let USERID_RULE = "[A-Za-z0-9]{5,20}"
    static let USERPW_RULE = "[A-Za-z0-9!_@$%^&+=]{8,16}"
    
    static let PW_ERROR_MESSAGE = "비밀번호는 8-16자의 영문, 숫자, 기호만 사용 가능합니다."
    static let PWVERIFY_ERROR_MESSAGE = "비밀번호가 일치하지 않습니다."
    
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
