//
//  Extensions.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/09.
//

import Foundation
import UIKit.UIView
import UIKit.UIColor
import UIKit.UITextField
import MaterialComponents.MaterialTextControls_OutlinedTextFields

let dateFormatter = DateFormatter() //2020-01-29

extension String {
    func toDate() -> Date? {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)
    }
}

extension Date {
    func toString() -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}

extension UIView {
    func makeShadow(color: CGColor = UIColor.lightGray.cgColor, offset: CGSize = .zero, radius: CGFloat = 10.0, opcity: Float = 0.9) {
        self.layer.shadowColor = color
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opcity
    }
    
    func makeBorder(color: CGColor = UIColor.black.cgColor, width: CGFloat = CGFloat(1.0), cornerRadius: CGFloat = CGFloat(0.0)) {
        self.layer.borderColor = color
        self.layer.borderWidth = width
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = cornerRadius > 0
    }
}

extension UIColor {
    static var mainColor: UIColor {
        return Constants.mainColor
    }
}

extension UIImage {
    static var personFill: UIImage {
        return UIImage(systemName: "person.fill")!
    }
    
    static var lockFill: UIImage {
        return UIImage(systemName: "lock.fill")!
    }
    
    static var xmarkCircleFill: UIImage {
        return UIImage(systemName: "xmark.circle.fill")!
    }
}

open class PaddedTextField: UITextField {
    public var textInsets = UIEdgeInsets.zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
}

extension MDCOutlinedTextField {
    func setNormalColor(color: UIColor) {
        
    }
}
