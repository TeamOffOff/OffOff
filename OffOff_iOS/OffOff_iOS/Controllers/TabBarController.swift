//
//  TabBarController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/03.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.tabBar.shadowImage = UIImage()
        tabBar.tintColor = Constants.mainColor
        setupVCs()
    }
    
    fileprivate func createNavController(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController()
        navController.viewControllers = [rootViewController]
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image.resize(to: CGSize(width: 26.adjustedWidth, height: 26.adjustedWidth))
        
        navController.navigationBar.barTintColor = .mainColor
        navController.navigationBar.prefersLargeTitles = false
        return navController
    }
    
    fileprivate func createViewController(for vc: UIViewController, title: String?, image: UIImage) -> UIViewController {
        vc.tabBarItem.title = title
        vc.tabBarItem.image = image.resize(to: CGSize(width: 26.adjustedWidth, height: 26.adjustedWidth))
        
        return vc
    }
    
    func setupVCs() {
        viewControllers = [
            // TODO: 첫 번째 tab의 navigation bar가 작아지는 문제
            createViewController(for: BoardListViewController(), title: nil, image: .HOMEICON),
            createNavController(for: UIViewController(), title: NSLocalizedString("프로필", comment: ""), image: UIImage(systemName: "person")!),
            createNavController(for: ScheduleViewController(), title: NSLocalizedString("스케쥴", comment: ""), image: UIImage(systemName: "person")!),
            createNavController(for: UIViewController(), title: NSLocalizedString("프로필", comment: ""), image: UIImage(systemName: "person")!),
            createNavController(for: UIViewController(), title: NSLocalizedString("프로필", comment: ""), image: UIImage(systemName: "person")!)
        ]
    }
    
}

//#if canImport(SwiftUI) && DEBUG
//import SwiftUI
//@available (iOS 13.0, *)
//struct TabBarPreview: PreviewProvider{
//    static var previews: some View {
//        TabBarController().showPreview(.iPhone8)
//    }
//}
//#endif
