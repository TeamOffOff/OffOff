//
//  PostView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/09.
//

import UIKit
import RxSwift

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
    var lineView = UIView().then {
        $0.backgroundColor = .g2
    }
    var profileImageView = UIImageView(image: .DEFAULT_PROFILE).then {
        $0.contentMode = .scaleAspectFit
    }
    var authorLabel = UILabel().then {
        $0.font = .defaulFont(size: 15, weight: .black)
        $0.adjustsFontForContentSizeCategory = true
        $0.textAlignment = .left
        $0.text = "작성자"
        $0.textColor = .white
    }
    var dateLabel = UILabel().then {
        $0.font = .defaulFont(size: 12, weight: .regular)
        $0.adjustsFontForContentSizeCategory = true
        $0.textAlignment = .left
        $0.textColor = .gray
        $0.text = "2021년 11월 11일"
        $0.textColor = .white
    }
    var likeButton = ButtonWithLeftIcon(frame: .zero, image: .LikeIconBold, title: "공감", iconPadding: 7.adjustedHeight, textPadding: 7.3.adjustedHeight, iconSize: CGSize(width: 11, height: 11).resized(basedOn: .height)).then {
        $0.textLabel.textColor = .g4
        $0.textLabel.font = .defaultFont(size: 12, bold: true)
        $0.backgroundColor = .g1
        $0.tintColor = .g4
        $0.setCornerRadius(8.adjustedHeight)
    }
    var scrapButton = ButtonWithLeftIcon(frame: .zero, image: .ScrapIconBold, title: "스크랩", iconPadding: 7.adjustedHeight, textPadding: 7.3.adjustedHeight, iconSize: CGSize(width: 11, height: 11).resized(basedOn: .height)).then {
        $0.textLabel.textColor = .g4
        $0.textLabel.font = .defaultFont(size: 12, bold: true)
        $0.backgroundColor = .g1
        $0.tintColor = .g4
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
        $0.separatorStyle = .none
    }
    
    var imageTableView = ContentSizedTableView().then {
        $0.register(ImageTableViewCell.self, forCellReuseIdentifier: ImageTableViewCell.identifier)
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.isScrollEnabled = false
        $0.allowsSelection = true
    }
    
    var likeLabel = TextWithIconView().then {
        $0.label.textColor = .white
        $0.label.font = .defaultFont(size: 12)
        $0.iconImageView.image = .LIKEICON
        $0.iconImageView.snp.updateConstraints {
            $0.width.height.equalTo(10.adjustedHeight)
        }
        $0.iconImageView.contentMode = .scaleAspectFit
        $0.iconImageView.tintColor = .white
        $0.label.text = "0"
    }
    var replyLabel = TextWithIconView().then {
        $0.label.textColor = .white
        $0.label.font = .defaultFont(size: 12)
        $0.iconImageView.image = .REPLYICON
        $0.iconImageView.snp.updateConstraints {
            $0.width.height.equalTo(10.adjustedHeight)
        }
        $0.iconImageView.contentMode = .scaleAspectFit
        $0.iconImageView.tintColor = .white
        $0.label.text = "0"
    }
    var scrapLabel = TextWithIconView().then {
        $0.label.textColor = .white
        $0.label.font = .defaultFont(size: 12)
        $0.iconImageView.image = .ScrapIcon
        $0.iconImageView.tintColor = .white
        $0.label.text = "0"
    }
    
    lazy var activityStack = UIStackView(arrangedSubviews: [likeLabel, replyLabel, scrapLabel]).then {
        $0.spacing = 10.0.adjustedWidth
        $0.axis = .horizontal
        $0.backgroundColor = .g4
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
        self.addSubview(lineView)
        self.addSubview(profileImageView)
        self.addSubview(activityStack)
        self.addSubview(likeButton)
        self.addSubview(scrapButton)
        self.addSubview(repliesTableView)
        self.addSubview(imageTableView)
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
            $0.top.equalTo(lineView.snp.bottom).offset(20.adjustedHeight)
        }
        contentTextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
        imageTableView.snp.makeConstraints {
            $0.top.equalTo(textContainerView.snp.bottom).offset(20.adjustedHeight)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(324.adjustedWidth)
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
        lineView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(1)
            $0.width.equalTo(324.adjustedWidth)
            $0.top.equalTo(titleLabel.snp.bottom).offset(15.adjustedHeight)
        }
        activityStack.snp.makeConstraints {
            $0.top.equalTo(imageTableView.snp.bottom).offset(20.adjustedHeight)
            $0.left.equalTo(profileImageView)
        }
        likeButton.snp.makeConstraints {
            let likeButtonSize = CGSize(width: 52, height: 23).resized(basedOn: .height)
            $0.top.equalTo(activityStack.snp.bottom).offset(8.adjustedHeight)
            $0.left.equalTo(profileImageView)
            $0.width.equalTo(likeButtonSize.width)
            $0.height.equalTo(likeButtonSize.height)
        }
        scrapButton.snp.makeConstraints {
            let scrapButtonSize = CGSize(width: 66, height: 23).resized(basedOn: .height)
            $0.top.equalTo(likeButton)
            $0.left.equalTo(likeButton.snp.right).offset(6.adjustedWidth)
            $0.width.equalTo(scrapButtonSize.width)
            $0.height.equalTo(scrapButtonSize.height)
        }
        
        repliesTableView.snp.makeConstraints {
            $0.top.equalTo(backgroundView.snp.bottom).offset(14.adjustedHeight)
            $0.bottom.equalToSuperview().inset(50.adjustedHeight)
            $0.width.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
    }
    
    func setupView(post: PostModel) {
        titleLabel.text = post.title
        dateLabel.text = post.date
        contentTextView.text = post.content
        if let author = post.author {
            authorLabel.text = author.nickname
        } else {
            authorLabel.text = "알 수 없음"
        }
        
    }
}

class ImageTableViewCell: UITableViewCell {
    static let identifier = "ImageTableViewCell"
    
    var photoView = UIImageView()
    
    var image = BehaviorSubject<UIImage?>(value: nil)
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(photoView)
        
        self.photoView.setCornerRadius(10.adjustedHeight)
        self.photoView.backgroundColor = .g4
        self.photoView.contentMode = .scaleAspectFill
        photoView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(10.adjustedHeight)
        }
        self.backgroundColor = .g4
    
        setData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setData()
    }
    
    private func setData() {
        disposeBag = DisposeBag()
        
        image
            .bind { [weak self] image in
                if image != nil {
                    self?.photoView.image = image!
                }
            }
            .disposed(by: disposeBag)
    }
}
