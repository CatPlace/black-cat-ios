//
//  UIScrollView+Rx.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/27.
//

import UIKit
import RxSwift

extension Reactive where Base: UIScrollView {
    /// Device Height의 반 이상 스크롤 할 경우 현재 보고 있는 페이지의 다음 페이지 Index값을 알려줍니다.
    var nextFetchPage: Observable<Int> {
        return didScroll.map { _ in
            let offset = base.contentOffset.y
            let screenHeight = UIScreen.main.bounds.height * 0.7
            let nextFetchPage = Int(offset / (screenHeight / 2))
            
            return nextFetchPage
        }
    }
}
