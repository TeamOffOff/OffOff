//
//  CustomRefreshControl.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/11/12.
//

import UIKit

class CustomRefreshControl: UIRefreshControl {
    let animationView = UIImageView()
    let progressView = UIImageView()
    var isAnimating = false
    
    fileprivate let maxPullDistance: CGFloat = 105
    
    override init() {
        super.init(frame: .zero)
        self.animationView.image = UIImage(named: "LoadingIndicator")!
        setImage()
        setupView()
        self.endRefreshing()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateProgress(with offsetY: CGFloat) {
        guard !isAnimating else { return }
        let progress = min(abs(offsetY / maxPullDistance), 1) * 10
        
        if progress >= 0 && progress < 2.5 {
            animationView.image = animationView.animationImages![0]
        } else if progress >= 2.5 && progress < 5.0 {
            animationView.image = animationView.animationImages![1]
        } else if progress >= 5.0 && progress < 7.5 {
            animationView.image = animationView.animationImages![2]
        } else {
            animationView.image = animationView.animationImages![3]
        }
        
    }

    override func beginRefreshing() {
        super.beginRefreshing()
        isAnimating = true
//        animationView.startAnimating()
        animationView.rotate(duration: 2.0)
    }
    
    override func endRefreshing() {
        super.endRefreshing()
//        animationView.stopAnimating()
        print(#fileID, #function, #line, "")
        animationView.stopRotating()
        isAnimating = false
    }
    
    // MARK: - Setup funcs
    private func setImage() {
        var images: [UIImage] = []
        for idx in 0...3 {
            images.append(UIImage(named: "LoadingProgress_0\(idx)")!)
        }
        
        animationView.animationImages = images
        animationView.animationDuration = 0.5
    }
    
    private func setupView() {
        // hide default indicator view
        tintColor = .clear
        addSubview(animationView)
        
        animationView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(30.adjustedWidth)
            $0.height.equalTo(30.adjustedHeight)
        }
        
        addTarget(self, action: #selector(beginRefreshing), for: .valueChanged)
    }
}
