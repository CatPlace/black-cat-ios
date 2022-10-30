//
//  BPReviewModel.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import Foundation

struct BPReviewModel {
    var imageUrlString: String
    
    init(imageUrlString: String) {
        self.imageUrlString = imageUrlString
    }
}

extension BPReviewModel {
    static func fetch() -> [BPReviewModel] {
        var result: [BPReviewModel] = []
        (0...50).forEach { _ in
            result += [BPReviewModel(imageUrlString: String.createRandomString(length: 5))]
        }
        return result
    }
}

