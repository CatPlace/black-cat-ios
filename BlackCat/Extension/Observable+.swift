//
//  Observable+.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/27.
//

import UIKit
import RxSwift

extension Observable where Element: Hashable {
    /// 이전에 발생한 이벤트가 새로 발생할 경우 해당 이벤트는 무시합니다
    func distinct() -> Observable<Element> {
        var cache = Set<Element>()
        return flatMap { element -> Observable<Element> in
            if let temp = element as? Int, temp == -1 {
                cache = Set<Element>()
            }
            if cache.contains(element) {
                return Observable<Element>.empty()
            } else {
                cache.insert(element)
                return Observable<Element>.just(element)
            }
        }
    }
}
