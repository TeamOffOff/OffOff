//
//  BoardListViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/03.
//

import UIKit
import RxSwift

class BoardListViewController: UIViewController {
    
    var customView = BoardListView()
    
    let disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = customView
        self.customView.boardCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
        self.customView.nicknameLabel.text = "\(Constants.loginUser!.subInformation.nickname) 님"
        
        self.customView.postListTableView.rowHeight = 81.adjustedHeight
        self.customView.postListTableView.separatorStyle = .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = BoardListViewModel(searchText: self.customView.boardSearchView.rx.text.asObservable())
        
        viewModel.boardLists
            .observe(on: MainScheduler.instance)
            .bind(to: customView.boardCollectionView.rx.items(cellIdentifier: BoardCollectionViewCell.identifier, cellType: BoardCollectionViewCell.self)) { (row, element, cell) in
                cell.titleLabel.text = element.name
                cell.badge.isHidden = !element.newPost
            }.disposed(by: disposeBag)
        

        self.customView.boardCollectionView
            .rx.modelSelected(Board.self)
            .bind { [weak self] in
                let vc = PostListViewController()
                vc.boardType = $0.boardType
                vc.boardName = $0.name
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                nav.navigationBar.setAppearance()
                self?.present(nav, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        // bind result
        viewModel.isSearching
            .bind { [weak self] in
                self?.customView.postListTableView.isHidden = !$0
                self?.customView.boardCollectionView.isHidden = $0
            }
            .disposed(by: disposeBag)

        viewModel.searchResults
            .observe(on: MainScheduler.instance)
            .bind(to: customView.postListTableView.rx.items(cellIdentifier: PostPreviewCell.identifier, cellType: PostPreviewCell.self)) { (row, element, cell) in
                cell.postModel.accept(element)
            }
            .disposed(by: disposeBag)
    }
}

extension BoardListViewController: UICollectionViewDelegateFlowLayout {
    // 한 가로줄에 cell이 3개만 들어가도록 크기 조정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 92.adjustedWidth, height: 92.adjustedHeight)
    }
}
