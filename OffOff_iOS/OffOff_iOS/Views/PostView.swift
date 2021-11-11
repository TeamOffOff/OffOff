//
//  PostView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/09.
//

import UIKit

class PostView: UIScrollView {
    var backgroundView = UIView().then {
        $0.backgroundColor = .g4
//        $0.clipsToBounds = true
        $0.layer.cornerRadius = 30.adjustedHeight
        $0.layer.maskedCorners = [.layerMaxXMaxYCorner]
    }
    var titleLabel = UILabel().then {
        $0.font = .defaultFont(size: 18, bold: true)
        $0.adjustsFontForContentSizeCategory = true
        $0.textAlignment = .left
        $0.text = "타이틀"
        $0.textColor = .white
    }
    var profileImageView = UIImageView(image: .DEFAULT_PROFILE).then {
        $0.contentMode = .scaleAspectFit
    }
    var authorLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .body).bold()
        $0.adjustsFontForContentSizeCategory = true
        $0.textAlignment = .left
        $0.text = "작성자"
        $0.textColor = .white
    }
    var dateLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .caption1)
        $0.adjustsFontForContentSizeCategory = true
        $0.textAlignment = .left
        $0.textColor = .gray
        $0.text = "2021년 11월 11일"
        $0.textColor = .white
    }
    var likeButton = UIButton().then {
        $0.setTitleColor(.g4, for: .normal)
        $0.setTitle("ㅇ 공감", for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.titleLabel?.font = .defaultFont(size: 9, bold: true)
        $0.backgroundColor = .g1
        $0.setCornerRadius(8.adjustedHeight)
    }
    var scrapButton = UIButton().then {
        $0.setTitleColor(.g4, for: .normal)
        $0.setTitle("ㅇ 스크랩", for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.titleLabel?.font = .defaultFont(size: 9, bold: true)
        $0.backgroundColor = .g1
        $0.setCornerRadius(8.adjustedHeight)
    }
    var contentTextView = UITextView().then {
        $0.textContainerInset = .zero
        $0.textContainer.lineFragmentPadding = 0

        $0.isUserInteractionEnabled = false
        $0.font = .defaultFont(size: 14)
        $0.adjustsFontForContentSizeCategory = true
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.sizeToFit()
        $0.isScrollEnabled = false
        $0.textContainer.lineBreakMode = .byCharWrapping
        $0.text =
            """
            Lorem Ipsum is simply dummy text of the printing and typesetting <image1> industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
            """
        $0.textColor = .white
        $0.backgroundColor = .g4
    }
    var informationStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.distribution = .fillEqually
    }
    var scrollView = UIScrollView()
    var textContainerView = UIView().then {
        $0.backgroundColor = .yellow
    }
    
    var repliesTableView = ContentSizedTableView().then {
        $0.register(RepliesTableViewCell.self, forCellReuseIdentifier: RepliesTableViewCell.identifier)
        $0.register(ChildrenRepliesTableViewCell.self, forCellReuseIdentifier: ChildrenRepliesTableViewCell.identifier)
        $0.isScrollEnabled = false
        $0.allowsSelection = false
        $0.rowHeight = 82.adjustedHeight
        $0.separatorStyle = .none
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(backgroundView)
        self.addSubview(textContainerView)
        self.textContainerView.addSubview(contentTextView)
        self.addSubview(informationStackView)
        informationStackView.addArrangedSubview(authorLabel)
        informationStackView.addArrangedSubview(dateLabel)
        self.addSubview(titleLabel)
        self.addSubview(profileImageView)
        self.addSubview(likeButton)
        self.addSubview(scrapButton)
        self.addSubview(repliesTableView)
        self.makeView()
    }   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeView() {
        backgroundView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalToSuperview()
            $0.bottom.equalTo(likeButton.snp.bottom).offset(31.adjustedHeight)
        }
        textContainerView.snp.makeConstraints {
            $0.width.equalTo(327.adjustedWidth)
            $0.left.equalTo(profileImageView)
            $0.top.equalTo(titleLabel.snp.bottom).offset(16.adjustedHeight)
        }
        contentTextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20.adjustedHeight)
            $0.left.equalToSuperview().inset(32.adjustedWidth)
            $0.width.height.equalTo(33.14.adjustedWidth)
        }
        informationStackView.snp.makeConstraints {
            $0.top.bottom.equalTo(profileImageView)
            $0.left.equalTo(profileImageView.snp.right).offset(8.9.adjustedWidth)
            $0.right.equalToSuperview().inset(12)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(20.adjustedHeight)
            $0.left.equalTo(profileImageView)
            $0.right.equalToSuperview().inset(30.adjustedWidth)
        }
        likeButton.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(8)
            $0.left.equalTo(profileImageView)
            $0.width.equalTo(43.adjustedWidth)
            $0.height.equalTo(20.adjustedHeight)
        }
        scrapButton.snp.makeConstraints {
            $0.top.equalTo(likeButton)
            $0.left.equalTo(likeButton.snp.right).offset(6.adjustedWidth)
            $0.width.equalTo(51.adjustedWidth)
            $0.height.equalTo(20.adjustedHeight)
        }
        
        repliesTableView.snp.makeConstraints {
            $0.top.equalTo(backgroundView.snp.bottom).offset(14.adjustedHeight)
            $0.bottom.equalToSuperview()
            $0.width.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
    }
    
    func setupView(post: PostModel) {
        titleLabel.text = post.title
        authorLabel.text = post.author.nickname
        dateLabel.text = post.date
        contentTextView.text = post.content
    }
}
