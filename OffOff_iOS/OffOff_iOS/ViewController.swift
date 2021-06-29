//
//  ViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/06/28.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let testView = TestView(frame: .zero)
        view.addSubview(testView)
        testView.setupView()
        testView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct PreviewController: PreviewProvider{
    static var previews: some View {
        ViewController().showPreview(.iPhone11Pro)
    }
}
#endif
