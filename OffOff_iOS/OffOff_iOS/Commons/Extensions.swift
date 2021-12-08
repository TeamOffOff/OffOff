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
import UIKit

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
    func toImage() -> UIImage {
        let imageData = Data.init(base64Encoded: self, options: .init(rawValue: 0))
        let image = UIImage(data: imageData!)
        return image!
    }
    
    func toDate(format: String = "yyyy년 MM월 dd일 HH시 mm분") -> Date? {
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
    func toDate(_ format: String) -> Date? {
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}

extension Date {
    func toFormedString() -> String {
        if self.isToday {
            return self.toString("HH:mm")
        } else if self.isThisYear {
            return self.toString("MM/dd HH:mm")
        } else {
            return self.toString("yy/MM/dd HH:mm")
        }
    }
    
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
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var isThisYear: Bool {
        return self.isSame(with: Date(), component: .year)
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
    
    func removeBorder() {
        self.layer.borderColor = nil
        self.layer.borderWidth = 0
        self.layer.cornerRadius = 0
    }
    
    func setCornerRadius(_ radius: Double) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = radius > 0
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func topRoundCorner(radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner] // Top right corner, Top left corner respectively
    }
    
    func bottomRoundCorner(radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
}

extension UIColor {
    static var w1: UIColor {
        return UIColor(hex: "FFFFFF")
    }
    
    static var w2: UIColor {
        return UIColor(hex: "F1F3F4")
    }
    
    static var w3: UIColor {
        return UIColor(hex: "DEE1E6")
    }
    
    static var w4: UIColor {
        return UIColor(hex: "C4C4C4")
    }
    
    static var w5: UIColor {
        return UIColor(hex: "626365")
    }
    
    static var w6: UIColor {
        return UIColor(hex: "000000")
    }
    
    static var g1: UIColor {
        return UIColor(hex: "BAC9C2")
    }
    
    static var g2: UIColor {
        return UIColor(hex: "6D9570")
    }
    
    static var g3: UIColor {
        return UIColor(hex: "598672")
    }
    
    static var g4: UIColor {
        return UIColor(hex: "18573A")
    }
    
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
    var imageRatio: CGFloat {
        let imageRatio = CGFloat(self.size.width / self.size.height)
        return imageRatio
    }
    
    func toBase64String() -> String {
        return self.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    
    func resize(to size: CGSize, isAlwaysTemplate: Bool = true) -> UIImage {
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        
        if isAlwaysTemplate {
            return renderImage.withRenderingMode(.alwaysTemplate)
        } else {
            return renderImage
        }
        
    }
    
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
    
    static let LEFTARROW = UIImage(named: "LeftArrow")!
    static let CAMERA = UIImage(named: "CameraImage")!.withRenderingMode(.alwaysTemplate)
    static let MOREICON = UIImage(named: "MoreIcon")!.withRenderingMode(.alwaysTemplate)
    static let SEARCHIMAGE = UIImage(named: "SearchImage")!
    
    static let DefaultPostProfileImage = UIImage(named: "DefaultPostProfileImage")!
    static let DefaultReplyProfileImage = UIImage(named: "DefaultReplyProfileImage")!
    static let SubReplyArrow = UIImage(named: "SubReplyArrow")!
    static let NewPostIcon = UIImage(named: "NewPostIcon")!.resize(to: CGSize(width: 26.61.adjustedWidth, height: 26.71.adjustedHeight))
    static let LIKEICON = UIImage(named: "LikeIcon")!.withRenderingMode(.alwaysTemplate)
    static let REPLYICON = UIImage(named: "ReplyIcon")!.withRenderingMode(.alwaysTemplate)
    static let PICTUREICON = UIImage(named: "PictureIcon")!.withRenderingMode(.alwaysTemplate)
    static let ScrapIcon = UIImage(named: "ScrapIcon")!.withRenderingMode(.alwaysTemplate)
    static let LikeIconFill = UIImage(named: "LikeIconFill")!.withRenderingMode(.alwaysTemplate)
    
    static let HOMEICON = UIImage(named: "HomeIcon")!
    static let SETTINGICON = UIImage(named: "SettingIcon")!
    static let CALENDARICON = UIImage(named: "CalendarIcon")!
    static let BOARDICON = UIImage(named: "BoardIcon")!
    static let PERSONICON = UIImage(named: "PersonIcon")!
    static let LikeIconBold = UIImage(named: "LikeIconBold")!.withRenderingMode(.alwaysTemplate)
    static let ScrapIconBold = UIImage(named: "ScrapIconBold")!.withRenderingMode(.alwaysTemplate)
    
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
    
    static func defaultFont(size: Double, bold: Bool = false) -> UIFont {
        let name = bold ? "Roboto-Bold" : "Roboto-Regular"
        return UIFont(name: name, size: size.adjustedHeight)!
    }
    
    static func defaulFont(size: Double, weight: FontWeightType) -> UIFont {
        return UIFont(name: "Roboto-\(weight.rawValue)", size: size.adjustedHeight)!
    }
}

enum FontWeightType: String {
    case regular = "Regular"
    case bold = "Bold"
    case black = "Black"
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

extension UINavigationBar {
    func setAppearance(titleColor: UIColor = .white, backgroundColor: UIColor = .mainColor) {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: titleColor]
        appearance.shadowColor = .g4
        appearance.setBackIndicatorImage(.LEFTARROW.resize(to: CGSize(width: 25.adjustedHeight, height: 22.adjustedHeight)), transitionMaskImage: .LEFTARROW.resize(to: CGSize(width: 25.adjustedHeight, height: 22.adjustedHeight)))
        self.isTranslucent = false
        self.tintColor = titleColor
        self.standardAppearance = appearance
        self.scrollEdgeAppearance = appearance
        self.compactAppearance = appearance
        if #available(iOS 15.0, *) {
            self.compactScrollEdgeAppearance = appearance
        }
        self.layoutIfNeeded()
    }
}

extension UIScrollView {
    func scrollToView(view:UIView, animated: Bool) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            self.scrollRectToVisible(CGRect(x:0, y:childStartPoint.y,width: 1,height: self.frame.height), animated: animated)
        }
    }
    
    func scrollToTop(animated: Bool) {
        let topOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topOffset, animated: animated)
    }
    
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        if(bottomOffset.y > 0) {
            setContentOffset(bottomOffset, animated: true)
        }
    }
    
    
    var minContentOffset: CGPoint {
        return CGPoint(
            x: -contentInset.left,
            y: -contentInset.top)
    }
    
    var maxContentOffset: CGPoint {
        return CGPoint(
            x: contentSize.width - bounds.width + contentInset.right,
            y: contentSize.height - bounds.height + contentInset.bottom)
    }
    
    func scrollToMinContentOffset(animated: Bool) {
        setContentOffset(minContentOffset, animated: animated)
    }
    
    func scrollToMaxContentOffset(animated: Bool) {
        setContentOffset(maxContentOffset, animated: animated)
    }
    
}

extension UIViewController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension Double {
    var adjustedWidth: Double {
        return (Double(UIScreen.main.bounds.size.width) * self) / CGSize.baseSize.width
    }
    
    var adjustedHeight: Double {
        return (Double(UIScreen.main.bounds.size.height) * self) / CGSize.baseSize.height
    }
}

enum Dimension {
    case width
    case height
}

extension CGSize {
    static var baseSize: CGSize {
        return CGSize(width: 390.0, height: 844.0)
    }
    
    func resized(basedOn dimension: Dimension) -> CGSize {
        let screenWidth  = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        var ratio:  CGFloat = 0.0
        var width:  CGFloat = 0.0
        var height: CGFloat = 0.0
        
        switch dimension {
        case .width:
            ratio  = self.height / self.width
            width  = screenWidth * (self.width / CGSize.baseSize.width)
            height = width * ratio
        case .height:
            ratio  = self.width / self.height
            height = screenHeight * (self.height / CGSize.baseSize.height)
            width  = height * ratio
        }
        
        return CGSize(width: width, height: height)
    }
}

extension CGFloat {
    func adapted(to dimension: Dimension) -> CGFloat {
        let screenWidth  = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        var ratio: CGFloat = 0.0
        var resultDimensionSize: CGFloat = 0.0
        
        switch dimension {
        case .width:
            ratio = self / CGSize.baseSize.width
            resultDimensionSize = screenWidth * ratio
        case .height:
            ratio = self / CGSize.baseSize.height
            resultDimensionSize = screenHeight * ratio
        }
        
        return resultDimensionSize
    }
}

extension UITextField {
    func addLeftPadding(value: Double) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: value, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
    
    func addLeftImage(image: UIImage, size: Double) {
        let paddingView = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: self.frame.height))
        paddingView.image = image
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
    
    func leftImage(_ image: UIImage?, imageWidth: CGFloat, padding: CGFloat) {
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: padding, y: 0, width: imageWidth, height: frame.height)
        imageView.contentMode = .center
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: imageWidth + 2 * padding, height: frame.height))
        containerView.addSubview(imageView)
        leftView = containerView
        leftViewMode = .always
    }
}

extension UIBarButtonItem {
    static func searchButton() -> UIBarButtonItem {
        UIBarButtonItem(image: .SEARCHIMAGE.resize(to: CGSize(width: 20.adjustedHeight, height: 20.adjustedHeight)), style: .plain, target: nil, action: nil)
    }
    static func menuButton() -> UIBarButtonItem {
        UIBarButtonItem(image: .MOREICON.resize(to: CGSize(width: 4.adjustedHeight, height: 20.adjustedHeight)), style: .plain, target: nil, action: nil)
    }
}

extension UIView {
    private static let kRotationAnimationKey = "rotationanimationkey"
    
    func rotate(duration: Double = 1) {
        if layer.animation(forKey: UIView.kRotationAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float.pi * 2.0
            rotationAnimation.duration = duration
            rotationAnimation.repeatCount = Float.infinity
            
            layer.add(rotationAnimation, forKey: UIView.kRotationAnimationKey)
        }
    }
    
    func rotateWithoutAnimation(degree: Double) {
        self.transform = CGAffineTransform(rotationAngle: CGFloat(degree))
    }
    
    func stopRotating() {
        if layer.animation(forKey: UIView.kRotationAnimationKey) != nil {
            layer.removeAnimation(forKey: UIView.kRotationAnimationKey)
        }
    }
    
    func isRotating() -> Bool {
        return layer.animation(forKey: UIView.kRotationAnimationKey) != nil
    }
}

enum VerticalLocation: String {
    case bottom
    case top
}

extension UITabBar {
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 80.adjustedHeight // 원하는 길이
        return sizeThatFits
    }
}

extension UIView {
    func addShadow(location: VerticalLocation, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 5.0) {
        switch location {
        case .bottom:
            addShadow(offset: CGSize(width: 0, height: 10), color: color, opacity: opacity, radius: radius)
        case .top:
            addShadow(offset: CGSize(width: 0, height: -2.5), color: color, opacity: opacity, radius: radius)
        }
    }
    
    func addShadow(offset: CGSize, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 5.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
}
