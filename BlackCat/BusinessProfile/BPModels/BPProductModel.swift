//
//  BPProductModel.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import Foundation

// ๐ปโโ๏ธ NOTE: - BP prefix๋ ๋ ๋ฒ์ฉ์ฑ์ด ํ๋๋๋ค๋ฉด ๋ชจ๋ธ ์์น๋ฅผ ๋ชจ๋๋ก ์ฎ๊ธฐ๊ณ , ๋ค์ด๋ฐ์ ๋ณ๊ฒฝํด๋ ์ข์ต๋๋ค.
struct BPProductModel {
    var imageUrlString: String
    
    init(imageUrlString: String) {
        self.imageUrlString = imageUrlString
    }
}

extension BPProductModel {
    static func fetch() -> [BPProductModel] {
        var result: [BPProductModel] = []
        (0...100).forEach { _ in
            result += [BPProductModel(imageUrlString: "https://raw.githubusercontent.com/kean/Nuke/master/Documentation/NukeUI.docc/Resources/nukeui-preview.png")]
        }
        return result
    }
}
