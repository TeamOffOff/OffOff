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
    
    static let USERID_MAXLENGTH = 20
    static let USERPW_MAXLENGTH = 30
}

typealias TextField = SkyFloatingLabelTextFieldWithIcon
