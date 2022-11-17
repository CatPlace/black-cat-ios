//
//  BPPriceInfoModel.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/15.
//

import Foundation

struct BPPriceInfoModel {
    /** 데이터*/ var text: String
    
    init(text: String) {
        self.text = text
    }
}

extension BPPriceInfoModel {
    static func fetch() -> [BPPriceInfoModel] {
        let text = """
        ✅ 안녕하세요 천재 타투이스트
        
        레터링: 3억
        등판: 100억
        컬러: 1조
        이레즈미: 최고! 😥
        
        이건 테스트 문자열!
        
        이게 과연 백줄이 된다면?
                이게 과연 백줄이 된다면?
                이게 과연 백줄이 된다면?
                이게 과연 백줄이 된다면?
                이게 과연 백줄이 된다면?  이게 과연 백줄이 된다면?
                                이게 과연 백줄이 된다면?
                            이게 과연 백줄이 된다면?
                    이게 과연 백줄이 된다면?
                    이게 과연 백줄이 된다면?
                    이게 과연 백줄이 된다면?
                    이게 과연 백줄이 된다면?
                이게 과연 백줄이 된다면?
                이게 과연 백줄이 된다면?
                이게 과연 백줄이 된다면?
        이게 과연 백줄이 된다면?
                이게 과연 백줄이 된다면?이게 과연 백줄이 된다면?
                이게 과연 백줄이 된다면?이게 과연 백줄이 된다면?
                이게 과연 백줄이 된다면?이게 과연 백줄이 된다면?이게 과연 백줄이 된다면?
        👉👉👉👉👉👉
                        이게 과연 백줄이 된다면?
                        이게 과연 백줄이 된다면?
                        이게 과연 백줄이 된다면?
                이게 과연 백줄이 된다면?
                        이게 과연 백줄이 된다면?이게 과연 백줄이 된다면?
                        이게 과연 백줄이 된다면?이게 과연 백줄이 된다면?
                        이게 과연 백줄이 된다면?이게 과연 백줄이 된다면?이게 과연 백줄이 된다면?
        """
        
        return [BPPriceInfoModel(text: text)]
    }
}
