//
//  PostListTableViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/05.
//

// TODO: - 맨 위, 맨 아래로 스크롤 해서 새로운 데이터 로딩

import UIKit
import RxSwift

class PostListViewController: UITableViewController {
    var boardType: String?
    var boardName: String?
    let disposeBag = DisposeBag()
    
    override func loadView() {
        self.tableView = .init()
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        self.title = boardName ?? ""
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.barTintColor = .mainColor
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: nil, action: nil)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.register(PostPreviewCell.classForCoder(), forCellReuseIdentifier: PostPreviewCell.identifier)
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .mainColor
    }
    
    override func viewDidLoad() {
        self.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        // view model
        let viewModel = PostListViewModel(boardType: boardType ?? "")
        
        // bind result
        viewModel.postList
            .bind(to: self.tableView.rx.items(cellIdentifier: PostPreviewCell.identifier, cellType: PostPreviewCell.self)) { (row, element, cell) in
                cell.titleLabel.text = element.Title
                cell.dateAuthorLabel.text = "\(element.Date) | \(element.Author)"
                cell.previewTextView.text = element.Content
                cell.likeLabel.label.text = "\(element.Likes) "
                cell.commentLabel.label.text = "\(element.reply_count)"
            }
            .disposed(by: disposeBag)
        
        // select row
        self.tableView.rx
            .modelSelected(PostModel.self)
            .bind {
                let vc = PostViewController()
                vc.postInfo = (id: $0._id, type: $0.board_type)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        // inputs
        self.navigationItem.leftBarButtonItem?
            .rx.tap
            .bind { self.dismiss(animated: true, completion: nil) }
            .disposed(by: disposeBag)
        
        self.navigationItem.rightBarButtonItem?
            .rx.tap
            .bind { self.navigationController?.pushViewController(NewPostViewController(), animated: true) }
            .disposed(by: disposeBag)
    }
}

// MARK: - Table view data source, delegate
extension PostListViewController {
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
