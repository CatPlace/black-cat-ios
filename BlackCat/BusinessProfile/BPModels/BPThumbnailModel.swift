//
//  BPThumbnailModel.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import Foundation

struct BPThumbnailModel {
    /** thumbnail 이미지 urlString */ var urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
    }
}

extension BPThumbnailModel {
    // MOCK
    static func fetch() -> [BPThumbnailModel] {
        var result: [BPThumbnailModel] = []
        (0...4).forEach { _ in
            result += [BPThumbnailModel(urlString: String.createRandomString(length: 5))]
        }
        return result
    }
}

// 🐻‍❄️ NOTE: - Mock사용하고 나중에 지우기
extension String {
    static func createRandomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String(
            (0..<length)
                .map { _ in letters.randomElement()! }
        )
    }
}
