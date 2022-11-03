//
//  BPReviewModel.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import Foundation

struct BPReviewModel {
    /** 썸네일 이미지 urlString */ var thumbnailImageUrlString: String
    /** 리뷰 점수 */ var ratingScore: RatingScroreType // NOTE: - enum으로 정의해서 사용할지
    /** 리뷰 제목 */ var reviewTitle: String
    /** 리뷰 설명 */ var reviewDescription: String
    
    // 이건 내가보았을 때 그냥 이미지 경로 매핑하는게 나을 수도 있겠다 ㅎㅎ,,
    enum RatingScroreType: Double {
        case _0 = 0
        case _0half = 0.5
        case _1 = 1
        case _1half = 1.5
        case _2 = 2
        case _2half = 2.5
        case _3 = 3
        case _3half = 3.5
        case _4 = 4
        case _4half = 4.5
        case _5 = 5
    }
    
    init(
        thumbnailImageUrlString: String,
        ratingScore: RatingScroreType,
        reviewTitle: String,
        reviewDescription: String
    ) {
        self.thumbnailImageUrlString = thumbnailImageUrlString
        self.ratingScore = ratingScore
        self.reviewTitle = reviewTitle
        self.reviewDescription = reviewDescription
    }
}

extension BPReviewModel {
    static func fetch() -> [BPReviewModel] {
        var result: [BPReviewModel] = []
        (0...50).forEach { _ in
            let model = BPReviewModel(thumbnailImageUrlString: "", ratingScore: ._1, reviewTitle: "aaa", reviewDescription: "`2`1")
            result += [model]
        }
        return result
    }
}

