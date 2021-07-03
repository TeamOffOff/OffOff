//
//  Box.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/03.
//

import Foundation

final class Box<T> {
    typealias Listener = (T) -> Void
    
    var listener: Listener?     // value가 변경되면 실행할 클로져
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(listener: Listener?) { // listener 설정 및 실행
        self.listener = listener
        listener?(value)
    }
}
