//
//  PostView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/09.
//

import UIKit

class PostView: UIView {
    var titleLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .title2)
        $0.adjustsFontForContentSizeCategory = true
        $0.textAlignment = .left
        $0.text = "타이틀"
    }
    var profileImageView = CircularImageView(image: .DEFAULT_PROFILE).then {
        $0.layer.cornerRadius = Constants.SCREEN_SIZE.width / 15.0
    }
    var authorLabel = UILabel().then {
        $0.textAlignment = .left
        $0.text = "작성자"
    }
    var dateLabel = UILabel().then {
        $0.textAlignment = .left
        $0.textColor = .gray
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.text = "2021년 11월 11일"
    }
    var likeButton = UIButton().then {
        $0.setImage(.ICON_LIKES_RED, for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.setTitle("좋아요", for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
//        $0.contentHorizontalAlignment = .center
//        $0.semanticContentAttribute = .forceRightToLeft
//        $0.imageEdgeInsets = .init(top: 0, left: 15, bottom: 0, right: 15)
        $0.makeBorder()
    }
    var scrapButton = UIButton()
    var contentTextView = UITextView().then {
        $0.isUserInteractionEnabled = false
        $0.font = .preferredFont(forTextStyle: .body)
        $0.adjustsFontForContentSizeCategory = true
        $0.text =
            """
            Lorem Ipsum is simply dummy text of the printing and typesetting <image1> industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
            """
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(titleLabel)
        self.addSubview(profileImageView)
        self.addSubview(authorLabel)
        self.addSubview(dateLabel)
        self.addSubview(contentTextView)
        self.addSubview(likeButton)
        self.makeView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeView() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.left.equalToSuperview().inset(12)
            $0.right.equalToSuperview().offset(12)
        }
        likeButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel)
            $0.right.equalToSuperview()
            $0.height.equalTo(25)
        }
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.left.equalToSuperview().inset(12)
            $0.width.height.equalTo(Constants.SCREEN_SIZE.width / 7.5)
        }
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView)
            $0.left.equalTo(profileImageView.snp.right).offset(12)
        }
        dateLabel.snp.makeConstraints {
            $0.left.equalTo(authorLabel)
            $0.top.equalTo(authorLabel.snp.bottom).offset(3)
        }
        contentTextView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(12)
            $0.right.equalToSuperview().inset(12)
            $0.top.equalTo(profileImageView.snp.bottom).offset(8)
            $0.bottom.equalToSuperview().inset(10)
        }
    }
    
    func setupView(post: PostModel) {
        titleLabel.text = post.Title
        authorLabel.text = post.Author
        dateLabel.text = post.Date
        contentTextView.text = post.Content
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
@available(iOS 13.0, *)
struct LSDFLMFSDF: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let view = PostView()
            return view
        }.previewLayout(.sizeThatFits)
    }
}

#endif

