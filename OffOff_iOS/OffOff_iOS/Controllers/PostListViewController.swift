//
//  PostListTableViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/05.
//

// TODO: - 맨 위, 맨 아래로 스크롤 해서 새로운 데이터 로딩

import UIKit

class PostListViewController: UITableViewController {
    let postViewModel = PostsViewModel()
    var boardType = "free"
    
    override func loadView() {
        self.tableView = .init()
        self.title = "자유게시판" // TODO: 받아온 게시판 정보로 타이틀 지정 필요
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.barTintColor = .mainColor
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(onCloseButton))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(onNewPostButton))
        
        // 모델에 새로운 포스트가 들어오면 테이블뷰 리로드
        postViewModel.postList.bind { _ in
            self.tableView.reloadData()
        }
        postViewModel.fetchPostList(board_type: self.boardType)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.register(PostPreviewCell.classForCoder(), forCellReuseIdentifier: PostPreviewCell.identifier)
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .mainColor
    }
    
    @objc func onCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onNewPostButton() {
        self.navigationController?.pushViewController(NewPostViewController(), animated: true)
    }
    
    static func embededController() -> UINavigationController {
        let vc = UINavigationController(rootViewController: PostListViewController())
        vc.modalPresentationStyle = .fullScreen
        vc.navigationItem.setLeftBarButton(UIBarButtonItem(title: "Something Else", style: .plain, target: nil, action: nil), animated: true)
        
        return vc
    }
}

// MARK: - Table view data source, delegate
extension PostListViewController {
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
        cell.setData(post: postViewModel.getPost(index: indexPath.row)!)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PostViewController()
        postViewModel.fetchPost(index: indexPath.row) { (post) in
            vc.postBoxed = Box(post)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
