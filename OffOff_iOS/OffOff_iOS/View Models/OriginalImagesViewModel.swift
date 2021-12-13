//
//  OriginalImagesViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/12/11.
//

import Foundation
import UIKit.UIImage

import RxSwift

class OriginalImagesViewModel {
    var originalImages: Observable<[UIImage]>
    
    init(postInfo: (id: String, type: String)) {
        originalImages = PostServices.fetchOriginalImages(postId: postInfo.id, boardType: postInfo.type)
            .map {
                $0.map {
                    $0.body.toImage()
                }
            }
    }
}
