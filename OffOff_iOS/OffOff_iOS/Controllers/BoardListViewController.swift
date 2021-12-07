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

    var viewModel: BoardListViewModel!
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
        
        viewModel = BoardListViewModel(searchText: self.customView.boardSearchView.rx.text.orEmpty.asObservable())
        
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
        
        customView.postListTableView.rx
            .itemSelected
            .withUnretained(self)
            .bind { (owner, indexPath) in
                if let cell = owner.customView.postListTableView.cellForRow(at: indexPath) as? PostPreviewCell {
                    let vc = PostViewController()
                    vc.postInfo = (id: cell.postModel.value!._id!, type: cell.postModel.value!.boardType)
                    vc.title = "검색 결과"
                    vc.postCell = cell
//                    owner.navigationController?.pushViewController(vc, animated: true)
                    
                    let nav = UINavigationController(rootViewController: vc)
                    
                    owner.present(nav, animated: true, completion: nil)
                    owner.customView.postListTableView.deselectRow(at: indexPath, animated: false)
                }
            }
            .disposed(by: disposeBag)
        
        customView.scrapsButton
            .rx.tap
            .bind { [weak self] in
                let vc = PostListViewController()
                vc.boardType = "스크랩한 글"
                vc.boardName = "스크랩한 글"
                
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                nav.navigationBar.setAppearance()
                self?.present(nav, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        // bind result
        viewModel.isSearching
            .debug()
            .observe(on: MainScheduler.instance)
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
        
        // 전체 검색 결과 추가로드
        self.customView.postListTableView.rx.didEndDragging
            .withUnretained(self)
            .bind { (owner, _) in
                if ((owner.customView.postListTableView.contentOffset.y + owner.customView.postListTableView.frame.size.height) >= owner.customView.postListTableView.contentSize.height)
                {
                    owner.viewModel!.reloadTrigger.onNext(true)
                }
            }
            .disposed(by: disposeBag)
    }
}

extension BoardListViewController: UICollectionViewDelegateFlowLayout {
    // 한 가로줄에 cell이 3개만 들어가도록 크기 조정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 92, height: 92).resized(basedOn: .width)
    }
}
