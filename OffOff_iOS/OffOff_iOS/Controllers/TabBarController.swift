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
        tabBar.backgroundColor = .w2
        setupVCs()
    }
    
    fileprivate func createNavController(for rootViewController: UIViewController, title: String?, image: UIImage) -> UIViewController {
        let navController = UINavigationController()
        navController.viewControllers = [rootViewController]
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image.resize(to: CGSize(width: 26, height: 26).resized(basedOn: .height))
        navController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -20.adjustedHeight, right: 0)
        
        navController.navigationBar.barTintColor = .mainColor
        navController.navigationBar.prefersLargeTitles = false
        return navController
    }
    
    fileprivate func createViewController(for vc: UIViewController, title: String?, image: UIImage) -> UIViewController {
        vc.tabBarItem.title = title
        vc.tabBarItem.image = image.resize(to: CGSize(width: 26, height: 26).resized(basedOn: .height))
        vc.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -21.adjustedHeight, right: 0)
        return vc
    }
    
    func setupVCs() {
        viewControllers = [
            // TODO: 첫 번째 tab의 navigation bar가 작아지는 문제
//            createViewController(for: BoardListViewController(), title: nil, image: .HOMEICON),
//            createNavController(for: UIViewController(), title: nil, image: .BOARDICON),
//            createNavController(for: ScheduleViewController(), title: nil, image: .CALENDARICON),
//            createViewController(for: MyActivityViewController(), title: nil, image: .PERSONICON),
//            createNavController(for: UIViewController(), title: nil, image: .SETTINGICON)
            
            createViewController(for: BoardListViewController(), title: nil, image: .HOMEICON),
            createViewController(for: MyActivityViewController(), title: nil, image: .PERSONICON)
        ]
    }
    
}
