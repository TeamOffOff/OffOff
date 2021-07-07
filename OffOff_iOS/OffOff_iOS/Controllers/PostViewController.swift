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
        view.addSubview(postView)
        postView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
        }
        postView.makeView()
        print(#fileID, #function, #line, "")
    }
    
    override func viewDidLoad() {
        if postBoxed != nil {
            self.postView.setupView(post: self.postBoxed!.value)
        }
    }
}

class PostView: UIView {
    // information
    var profileImageView = UIImageView().then {
        $0.image = UIImage(systemName: "person")
    }
    var authorLabel = UILabel().then {
        $0.textAlignment = .left
        $0.text = "작성자"
    }
    var dateLabel = UILabel().then {
        $0.textAlignment = .left
        $0.text = "작성 날짜"
    }
    var informationView = UIView()
    var contentTextView = UITextView().then {
        $0.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        $0.text = "작성 내용"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeView() {
        informationView.addSubview(profileImageView)
        informationView.addSubview(authorLabel)
        informationView.addSubview(dateLabel)
        
        self.addSubview(informationView)
        self.addSubview(contentTextView)
    
        authorLabel.snp.makeConstraints {
            $0.left.equalTo(profileImageView.snp.right).offset(8)
            $0.right.equalToSuperview()
        }
        dateLabel.snp.makeConstraints {
            $0.left.equalTo(profileImageView.snp.right).offset(8)
            $0.top.equalTo(authorLabel.snp.bottom)
            $0.right.equalToSuperview()
        }
        profileImageView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().inset(8)
            $0.width.equalToSuperview().dividedBy(7.5)
            $0.height.equalTo(profileImageView.snp.width)
        }
        informationView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview().inset(8)
        }
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(informationView.snp.bottom).inset(8)
            $0.left.right.bottom.equalToSuperview().inset(8)
        }
    }
    
    func setupView(post: PostModel) {
        authorLabel.text = post.metadata.author
        dateLabel.text = post.metadata.date
        contentTextView.text = post.contents.content
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
