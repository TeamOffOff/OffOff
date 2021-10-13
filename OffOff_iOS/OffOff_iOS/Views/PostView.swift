//
//  PostView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/09.
//

import UIKit

class PostView: UIScrollView {
    var titleLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .title2).bold()
        $0.adjustsFontForContentSizeCategory = true
        $0.textAlignment = .left
        $0.text = "타이틀"
    }
    var profileImageView = UIImageView(image: .DEFAULT_PROFILE).then {
        $0.makeBorder(color: UIColor.clear.cgColor, cornerRadius: 10)
    }
    var authorLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .body).bold()
        $0.adjustsFontForContentSizeCategory = true
        $0.textAlignment = .left
        $0.text = "작성자"
    }
    var dateLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .caption1)
        $0.adjustsFontForContentSizeCategory = true
        $0.textAlignment = .left
        $0.textColor = .gray
        $0.text = "2021년 11월 11일"
    }
    var likeButton = UIButton().then {
        $0.setTitleColor(.black, for: .normal)
        $0.setTitle("0", for: .normal)
        $0.titleLabel?.textAlignment = .right
        $0.setImage(.ICON_LIKES_RED, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption1)
        $0.titleLabel?.adjustsFontForContentSizeCategory = true
    }
    var scrapButton = UIButton().then {
        $0.setImage(.ICON_SCRAP_YELLOW, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.setTitleColor(.black, for: .normal)
        $0.setTitle("스크랩", for: .normal)
        $0.titleLabel?.textAlignment = .right
        $0.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption1)
        $0.titleLabel?.contentMode = .scaleToFill
        $0.titleLabel?.adjustsFontForContentSizeCategory = true
    }
    var contentTextView = UITextView().then {
        $0.isUserInteractionEnabled = false
        $0.font = .preferredFont(forTextStyle: .body)
        $0.adjustsFontForContentSizeCategory = true
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.sizeToFit()
        $0.isScrollEnabled = false
        $0.textContainer.lineBreakMode = .byCharWrapping
        $0.text =
            """
            Lorem Ipsum is simply dummy text of the printing and typesetting <image1> industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
            """
    }
    var informationStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.distribution = .fillEqually
    }
    var scrollView = UIScrollView()
    var textContainerView = UIView()
    
    var repliesTableView = ContentSizedTableView().then {
        $0.backgroundColor = .white
        $0.register(RepliesTableViewCell.self, forCellReuseIdentifier: RepliesTableViewCell.identifier)
        $0.isScrollEnabled = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        print(#fileID, #function, #line, "")
        repliesTableView.snp.makeConstraints {
            $0.top.equalTo(likeButton.snp.bottom).offset(8.0)
            $0.left.right.bottom.equalToSuperview()
        }
        textContainerView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.width.equalToSuperview()
            $0.top.equalTo(profileImageView.snp.bottom)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.equalToSuperview().inset(12)
            $0.right.equalToSuperview().offset(12)
        }
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.left.equalToSuperview().inset(12)
            $0.width.height.equalTo(Constants.SCREEN_SIZE.width / 8.0)
        }
        informationStackView.snp.makeConstraints {
            $0.top.bottom.equalTo(profileImageView)
            $0.left.equalTo(profileImageView.snp.right).offset(12)
            $0.right.equalToSuperview().inset(12)
        }
        contentTextView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.height.equalToSuperview()
            $0.left.equalToSuperview().offset(12)
            $0.right.equalToSuperview().inset(12)
        }
        likeButton.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(8)
            $0.right.equalTo(scrapButton.snp.left)
            $0.width.equalTo(Constants.SCREEN_SIZE.width / 6.0)
        }
        scrapButton.snp.makeConstraints {
            $0.top.equalTo(likeButton)
            $0.right.equalToSuperview().inset(12)
            $0.width.equalTo(Constants.SCREEN_SIZE.width / 6.0)
        }
    }
    
    func setupView(post: PostModel) {
        titleLabel.text = post.title
        authorLabel.text = post.author.nickname
        dateLabel.text = post.date
        contentTextView.text = post.content
    }
}

final class ContentSizedTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
