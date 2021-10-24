//
//  ChildrenRepliesTableViewCell.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/10/19.
//

import UIKit
import RxSwift
import RxCocoa

class ChildrenRepliesTableViewCell: UITableViewCell {
    static let identifier = "ChildrenRepliesTableViewCell"

    var reply = BehaviorSubject<Reply?>(value: nil)
    var disposeBag = DisposeBag()
    
    var boardTpye: String?
    var activityAlert: ((_ title: String) -> Void)?
    var dismissAlert: ((_ animated: Bool) -> Void)?
    var presentMenuAlert: ((_ alert: UIAlertController) -> Void)?
    
    var replies = BehaviorSubject<[Reply]?>(value: nil)
    
    var profileImageView = UIImageView().then {
        $0.backgroundColor = .lightGray
    }
    
    var nicknameLabel = UILabel().then {
        $0.backgroundColor = .white
    }
    
    var dateLabel = UILabel().then {
        $0.backgroundColor = .white
    }
    
    var contentTextView = UITextView().then {
        $0.backgroundColor = .white
        $0.isScrollEnabled = false
        $0.sizeToFit()
        $0.isUserInteractionEnabled = false
    }
    
    var likeButton = UIButton().then {
        $0.setTitleColor(.black, for: .normal)
        $0.setTitle("0", for: .normal)
        $0.titleLabel?.textAlignment = .right
        $0.setImage(.ICON_LIKES_RED, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption1)
        $0.titleLabel?.adjustsFontForContentSizeCategory = true
        $0.contentHorizontalAlignment = .left
    }
    
    var menubutton = UIButton().then {
        $0.setTitle("...", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(profileImageView)
        self.contentView.addSubview(nicknameLabel)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(contentTextView)
        self.contentView.addSubview(likeButton)
        self.contentView.addSubview(menubutton)
        bindData()
        makeView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bindData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func makeView() {
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8.0)
            $0.left.equalToSuperview().inset(30)
            $0.width.height.equalTo(20.0)
        }
        nicknameLabel.snp.makeConstraints {
            $0.left.equalTo(profileImageView.snp.right).offset(8.0)
            $0.centerY.equalTo(profileImageView)
        }
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(8.0)
            $0.left.equalTo(profileImageView)
            $0.right.equalToSuperview()
        }
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(8.0)
            $0.left.equalTo(dateLabel)
            $0.right.equalToSuperview().inset(8.0)
        }
        likeButton.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(8.0)
            $0.left.equalTo(contentTextView)
            //            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        menubutton.snp.makeConstraints {
            $0.centerY.equalTo(nicknameLabel)
            $0.width.equalTo(20)
            $0.right.equalToSuperview().inset(8.0)
            $0.left.equalTo(nicknameLabel.snp.right)
        }
    }
    
    private func bindData() {
        disposeBag = DisposeBag()
        
        reply
            .filter { $0 != nil }
            .map { $0! }
            .bind {
                //            self.profileImageView.image =
                self.nicknameLabel.text = $0.author.nickname
                self.dateLabel.text = $0.date
                self.contentTextView.text = $0.content
                self.likeButton.setTitle("\($0.likes.count)", for: .normal)
            }
            .disposed(by: disposeBag)
    }
}
