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
        UITabBar.appearance().barTintColor = .systemBackground
        tabBar.tintColor = .label
        setupVCs()
    }
    
    fileprivate func createNavController(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController()
        rootViewController.edgesForExtendedLayout = [] // Navigation bar와 이 vc가 겹치지 않도록 하는 코드
        navController.viewControllers = [rootViewController]
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navController.navigationBar.prefersLargeTitles = false
        navController.navigationBar.backgroundColor = .green
        rootViewController.navigationItem.title = title
        return navController
    }
    
    func setupVCs() {
        viewControllers = [
            createNavController(for: HomeViewController(), title: NSLocalizedString("Home", comment: ""), image: UIImage(systemName: "house")!),
            createNavController(for: LoginViewController(), title: NSLocalizedString("Community", comment: ""), image: UIImage(systemName: "text.justify")!),
            createNavController(for: LoginViewController(), title: NSLocalizedString("Profile", comment: ""), image: UIImage(systemName: "person")!)
        ]
    }
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
@available (iOS 13.0, *)
struct TabBarPreview: PreviewProvider{
    static var previews: some View {
        TabBarController().showPreview(.iPhone11Pro)
    }
}
#endif
