//
//  BPContentModel.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import Foundation

struct BPContentModel {
    var order: Int
    
    init(order: Int) {
        self.order = order
    }
}

//extension BPContentModel {
//    // MOCK
//    static func fetch() -> [BPThumbnailModel] {
//        var result: [BPThumbnailModel] = []
//        (0...4).forEach { _ in
//            result += [BPThumbnailModel(urlString: String.createRandomString(length: 5))]
//        }
//        return result
//    }
//}
