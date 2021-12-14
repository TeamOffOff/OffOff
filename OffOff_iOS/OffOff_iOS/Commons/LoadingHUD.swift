//
//  LoadingHUD.swift
//  LoadingExample
//
//  Created by Fury on 31/05/2019.
//  Copyright © 2019 Fury. All rights reserved.
//

import Foundation
import UIKit

class LoadingHUD {
    private static let sharedInstance = LoadingHUD()
    
    private var backgroundView: UIView?
    private var popupView: UIImageView?
    
    class func show() {
        let backgroundView = UIView(frame: CGRect.init(x: 0, y: 0, width: 200, height: 200)).then {
            $0.backgroundColor = .yellow
        }
        
        let popupView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100)).then {
            $0.image = UIImage(named: "LodingIndicator")!.resize(to: CGSize(width: 50.adjustedWidth, height: 50.adjustedHeight), isAlwaysTemplate: false)
        }
        
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.addSubview(backgroundView)
            window.addSubview(popupView)
            
            backgroundView.frame = CGRect(x: 0, y: 0, width: window.frame.maxX, height: window.frame.maxY)
            backgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            
            popupView.center = window.center
            popupView.rotate(duration: 2.5)
//            LoadingHUD.rotateRefreshIndicator(true)
            
            sharedInstance.backgroundView?.removeFromSuperview()
            sharedInstance.popupView?.removeFromSuperview()

            sharedInstance.backgroundView = backgroundView
            sharedInstance.popupView = popupView
        }
    }
    
//    class func rotateRefreshIndicator(_ on: Bool) {
//        sharedInstance.popupView!.isHidden = !on
//
//        if on {
//            sharedInstance.popupView!.rotate(duration: 2.5)
//        } else {
//            sharedInstance.popupView!.stopRotating()
//        }
//    }
    
    class func hide() {
        if let popupView = sharedInstance.popupView,
        let backgroundView = sharedInstance.backgroundView {
            backgroundView.removeFromSuperview()
            popupView.removeFromSuperview()
        }
    }
}
