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
        let navController = UINavigationController(navigationBarClass: CustomNavigationBar.self, toolbarClass: nil)
        navController.viewControllers = [rootViewController]
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        
        navController.navigationBar.barTintColor = .mainColor
        navController.navigationBar.prefersLargeTitles = false
        
        if let navigationBar = navController.navigationBar as? CustomNavigationBar {
            navigationBar.titleLabel.text = title
            
        }
        
        return navController
    }
    
    func setupVCs() {
        viewControllers = [
            // TODO: 첫 번째 tab의 navigation bar가 작아지는 문제
            createNavController(for: CommunityListViewController(), title: NSLocalizedString("커뮤니티", comment: ""), image: UIImage(systemName: "house")!),
//            createNavController(for: PostListViewController(), title: NSLocalizedString("Community", comment: ""), image: UIImage(systemName: "text.justify")!),
            createNavController(for: UIViewController(), title: NSLocalizedString("프로필", comment: ""), image: UIImage(systemName: "person")!),
            createNavController(for: UIViewController(), title: NSLocalizedString("프로필", comment: ""), image: UIImage(systemName: "person")!),
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
