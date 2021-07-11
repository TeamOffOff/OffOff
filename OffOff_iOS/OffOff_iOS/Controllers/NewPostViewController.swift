//
//  NewPostViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/09.
//

import UIKit

class NewPostViewController: UIViewController {
    let newPostView = NewPostView()
    
    override func loadView() {
        self.view = .init()
        view.addSubview(newPostView)
        newPostView.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges).inset(8)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "글 쓰기"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onSaveButton))
    }
    
    // TODO:
    // 제목, 내용 비어있는지 검사
    @objc private func onSaveButton() {
        PostsViewModel.makeNewPost(title: newPostView.titleTextField.text!, content: newPostView.contentTextView.text!, board_type: "자유게시판")
        self.navigationController?.popViewController(animated: true)
    }
}

class NewPostView: UIStackView {
    var titleTextField = UITextField().then {
        $0.placeholder = "제목"
        $0.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
    }
    var contentTextView = UITextView().then {
        $0.font = UIFont.systemFont(ofSize: 18.0)
        $0.backgroundColor = .lightGray
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .vertical
        self.distribution = .fill
        self.spacing = 8
        self.addArrangedSubview(titleTextField)
        self.addArrangedSubview(contentTextView)
        self.makeView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeView() {
        
    }
    
    func setupView() {
        
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
@available (iOS 13.0, *)
struct Newpostpreview: PreviewProvider{
    static var previews: some View {
        NewPostViewController().showPreview(.iPhone11Pro)
    }
}
#endif
