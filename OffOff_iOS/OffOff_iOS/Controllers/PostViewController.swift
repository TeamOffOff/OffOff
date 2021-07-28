//
//  PostViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/06.
//

import UIKit

class PostViewController: UIViewController {
    var postView = PostView(frame: .zero)
    var postBoxed: Box<PostModel>?
    
    override func loadView() {
        self.view = .init()
        self.view.backgroundColor = .white
        view.addSubview(postView)
        postView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
        }
        postView.makeView()
    }
    
    override func viewDidLoad() {
        if postBoxed != nil {
            self.postView.setupView(post: self.postBoxed!.value)
        }
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
@available (iOS 13.0, *)
struct PostViewPreview: PreviewProvider{
    static var previews: some View {
        PostViewController().showPreview(.iPhone11Pro)
    }
}
#endif
