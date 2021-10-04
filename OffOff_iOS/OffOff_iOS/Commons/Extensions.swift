//
//  Extensions.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/09.
//

import RealmSwift
import SkyFloatingLabelTextField
import FontAwesome
import RxSwift

let dateFormatter = DateFormatter() //2020-01-29

protocol ViewModelType {
    associatedtype Dependency
    associatedtype Input
    associatedtype Output

    var dependency: Dependency { get }
    var disposeBag: DisposeBag { get set }
    
    var input: Input { get }
    var output: Output { get }
    
}

extension String {
    func toDate() -> Date? {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)
    }
    
    func toDate(_ format: String) -> Date? {
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}

extension Date {
    var startOfMonth: Date {
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        
        return  calendar.date(from: components)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    
    var isEndOfMonth: Bool {
        let calendar = Calendar.current
        
        return calendar.isDate(self, inSameDayAs: self.endOfMonth)
    }
    
    var day: Int {
        let calendar = Calendar.current
        return calendar.component(.day, from: self)
    }
    
    var month: Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: self)
    }
    
    var year: Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: self)
    }
    
    func toString(_ format: String = "yyyy년 MM월 dd일") -> String {
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func adjustDate(amount: Int, component: Calendar.Component) -> Date? {
        var dayComponent = DateComponents()
        
        switch component {
        case .day:
            dayComponent.day = amount
        case .month:
            dayComponent.month = amount
        case .year:
            dayComponent.year = amount
        default:
            return nil
        }
        let theCalendar = Calendar.current
        return theCalendar.date(byAdding: dayComponent, to: self)
    }
    
    func isSame(with date: Date, component: Calendar.Component) -> Bool {
        let calendar = Calendar.current
        
        if calendar.component(component, from: self) == calendar.component(component, from: date) {
            return true
        } else {
            return false
        }
    }
    
    func compareComponent(with date: Date, component: Calendar.Component) -> ComparisonResult {
        let calendar = Calendar.current
        
        if calendar.component(component, from: self) == calendar.component(component, from: date) {
            return .orderedSame
        }
        
        if calendar.component(component, from: self) > calendar.component(component, from: date) {
            return .orderedDescending
        }
        
        return .orderedAscending
    }
    
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        
        return Date(timeInterval: seconds, since: self)
        
    }
    
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        
        return Date(timeInterval: seconds, since: self)
        
    }
    
    func changeComponent(component: Calendar.Component, amount: Int) -> Date? {
        let calendar = Calendar.current
        
        return calendar.date(bySetting: component,  value: amount, of: self)
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
    
    // hex code로 UIColor 객체 생성
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}

extension UIImage {
    static var DEFAULT_PROFILE = UIImage(named: "default profile")
    
    static var personFill: UIImage {
        return UIImage(systemName: "person.fill")!
    }
    
    static var lockFill: UIImage {
        return UIImage(systemName: "lock.fill")!
    }
    
    static var xmarkCircleFill: UIImage {
        return UIImage(systemName: "xmark.circle.fill")!
    }
    
    static let ICON_USER_GRAY = UIImage.fontAwesomeIcon(name: .user, style: .solid, textColor: .systemGray, size: Constants.ICON_SIZE)
    static let ICON_LOCK_GRAY = UIImage.fontAwesomeIcon(name: .lock, style: .solid, textColor: .systemGray, size: Constants.ICON_SIZE)
    static let ICON_AT_GRAY = UIImage.fontAwesomeIcon(name: .at, style: .solid, textColor: .systemGray, size: Constants.ICON_SIZE)
    static let ICON_CHECKCIRCLE_GRAY = UIImage.fontAwesomeIcon(name: .checkCircle, style: .solid, textColor: .systemGray, size: Constants.ICON_SIZE)
    static let ICON_USER_MAINCOLOR = UIImage.fontAwesomeIcon(name: .user, style: .solid, textColor: .mainColor, size: Constants.ICON_SIZE)
    static let ICON_LOCK_MAINCOLOR = UIImage.fontAwesomeIcon(name: .lock, style: .solid, textColor: .mainColor, size: Constants.ICON_SIZE)
    static let ICON_AT_MAINCOLOR = UIImage.fontAwesomeIcon(name: .at, style: .solid, textColor: .mainColor, size: Constants.ICON_SIZE)
    static let ICON_CHECKCIRCLE_MAINCOLOR = UIImage.fontAwesomeIcon(name: .checkCircle, style: .solid, textColor: .mainColor, size: Constants.ICON_SIZE)
    static let ICON_EXCLAMATION_RED = UIImage.fontAwesomeIcon(name: .exclamation, style: .solid, textColor: .systemRed, size: Constants.ICON_SIZE)
    static let ICON_BIRTHDAY_GRAY = UIImage.fontAwesomeIcon(name: .birthdayCake, style: .solid, textColor: .systemGray, size: Constants.ICON_SIZE)
    static let ICON_BIRTHDAY_MAINCOLOR = UIImage.fontAwesomeIcon(name: .birthdayCake, style: .solid, textColor: .mainColor, size: Constants.ICON_SIZE)
    static let ICON_LIKES_RED = UIImage.fontAwesomeIcon(name: .thumbsUp, style: .regular, textColor: .systemRed, size: Constants.BUTTON_ICON_SIZE)
    static let ICON_COMMENT_BLUE = UIImage.fontAwesomeIcon(name: .commentAlt, style: .regular, textColor: .systemBlue, size: Constants.BUTTON_ICON_SIZE)
    static let ICON_SCRAP_YELLOW = UIImage.fontAwesomeIcon(name: .star, style: .regular, textColor: .systemYellow, size: Constants.BUTTON_ICON_SIZE)
    static let ICON_SEARCH_GRAY = UIImage.fontAwesomeIcon(name: .search, style: .solid, textColor: .systemGray, size: Constants.ICON_SIZE)
    static let ICON_REPORT_GRAY = UIImage.fontAwesomeIcon(name: .exclamationCircle, style: .solid, textColor: .systemGray, size: Constants.ICON_SIZE)
    static let ICON_WRITE_GRAY = UIImage.fontAwesomeIcon(name: .pen, style: .solid, textColor: .systemGray, size: Constants.BUTTON_ICON_SIZE)
    static let ICON_X_WHITE = UIImage.fontAwesomeIcon(name: .times, style: .solid, textColor: .white, size: Constants.ICON_SIZE)
    
    static func getIcon(name: FontAwesome, color: UIColor = .systemGray, size: CGSize = Constants.ICON_SIZE) -> UIImage {
        return UIImage.fontAwesomeIcon(name: name, style: .solid, textColor: color, size: size)
    }
    
    static func iconWrite(color: UIColor = .systemGray, size: CGSize = Constants.ICON_SIZE) -> UIImage {
        return UIImage.fontAwesomeIcon(name: .pen, style: .solid, textColor: color, size: size)
    }
}

extension TextField {
    func setupTextField(selectedColor: UIColor, normalColor: UIColor, iconImage: UIImage?, errorColor: UIColor) {
        self.lineColor = normalColor
        self.textColor = normalColor
        self.titleColor = normalColor
        
        self.selectedIconColor = selectedColor
        self.selectedLineColor = selectedColor
        self.selectedTitleColor = selectedColor
        
        self.iconType = .image
        self.iconImage = iconImage
        self.iconColor = normalColor
        self.selectedIconColor = selectedColor
        
        self.errorColor = errorColor
    }
    
    func setTextFieldNormal(iconImage: UIImage) {
        self.errorMessage = ""
        self.text = nil
        self.iconImage = iconImage
        self.lineColor = .gray
    }
    
    func setTextFieldFail(errorMessage: String) {
        self.errorMessage = errorMessage
        self.iconImage = .ICON_EXCLAMATION_RED
    }
    
    func setTextFieldVerified() {
        self.errorMessage = nil
        self.iconImage = .ICON_CHECKCIRCLE_MAINCOLOR
        self.lineColor = .mainColor
    }
    
    func isVerified() -> Bool {
        return self.iconImage == .ICON_CHECKCIRCLE_MAINCOLOR
    }
}

extension UIBarButtonItem {
    static func menuButton(_ target: Any?, action: Selector, image: UIImage) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: button)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        return menuBarItem
    }
}

extension UIView {
    func showAnimation(_ completionBlock: @escaping () -> Void) {
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.05,
                       delay: 0,
                       options: .curveLinear,
                       animations: { [weak self] in
                        self?.transform = CGAffineTransform.init(scaleX: 0.95, y: 0.95)
                       }) {  (done) in
            UIView.animate(withDuration: 0.05,
                           delay: 0,
                           options: .curveLinear,
                           animations: { [weak self] in
                            self?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                           }) { [weak self] (_) in
                self?.isUserInteractionEnabled = true
                completionBlock()
            }
                       }
    }
}

extension UIFont {
    func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }

    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }

    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
}


extension Results {
    // Realm Result를 Array로 convert
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        
        return array
    }
}

extension Realm {
    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}
