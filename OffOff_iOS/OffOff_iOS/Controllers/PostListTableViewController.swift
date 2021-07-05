//
//  PostListTableViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/05.
//

import UIKit

class PostListTableViewController: UITableViewController {
    let postViewModel = PostsViewModel()
    
    override func loadView() {
        super.loadView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.register(PostPreviewCell.classForCoder(), forCellReuseIdentifier: PostPreviewCell.identifier)
    }
}

// MARK: - Table view data source
extension PostListTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postViewModel.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostPreviewCell.identifier, for: indexPath) as? PostPreviewCell else {
            return UITableViewCell()
        }
        cell.backgroundColor = .green
        cell.setData(post: postViewModel.getPost(index: indexPath.row)!)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

class PostPreviewCell: UITableViewCell {
    static let identifier = "PostPreviewCell"
    
    var titleLabel = UILabel().then {
        $0.textAlignment = .left
    }
    var previewTextView = UILabel().then {
        $0.numberOfLines = 2
        #if DEBUG
        $0.backgroundColor = .red
        #endif
    }
    var authorLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.textAlignment = .right
    }
    var dateLabel = UILabel().then {
        $0.textColor = .lightGray
        #if DEBUG
        $0.backgroundColor = .blue
        #endif
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        addViews()
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.top.equalToSuperview().inset(8)
        }
        authorLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.right.equalToSuperview().inset(8)
            $0.left.equalTo(titleLabel.snp.left).inset(8)
        }
        dateLabel.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        previewTextView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().inset(12)
            $0.right.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(8)
        }
    }
    
    func setData(post: Post) {
        print(post.contents.content)
        titleLabel.text = post.metadata.title
        previewTextView.text = post.contents.content
        authorLabel.text = post.metadata.author
        dateLabel.text = post.metadata.date
    }
    
    private func addViews() {
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(authorLabel)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(previewTextView)
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
@available (iOS 13.0, *)
struct PostListPreview: PreviewProvider{
    static var previews: some View {
        PostListTableViewController().showPreview(.iPhone11Pro)
    }
}
#endif
