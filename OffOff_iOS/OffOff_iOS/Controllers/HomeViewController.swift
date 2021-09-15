//
//  HomeViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/03.
//

import UIKit

class HomeViewController: UIViewController {

    let homeView = HomeView(.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(homeView)
        homeView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(25)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
