//
//  BPProductModel.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import Foundation

// 🐻‍❄️ NOTE: - BP prefix는 더 범용성이 확대된다면 모델 위치를 모듈로 옮기고, 네이밍을 변경해도 좋습니다.
struct BPProductModel {
    var imageUrlString: String
    
    init(imageUrlString: String) {
        self.imageUrlString = imageUrlString
    }
}

extension BPProductModel {
    static func fetch() -> [BPProductModel] {
        var result: [BPProductModel] = []
        (0...4).forEach { _ in
            result += [BPProductModel(imageUrlString: String.createRandomString(length: 5))]
        }
        return result
    }
}
