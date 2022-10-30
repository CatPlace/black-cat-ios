//
//  BPContentCellService.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/31.
//

import Foundation

// MARK: - Service를 정의
protocol BPContentCellServiceProtocol {
    func fetchProducts() -> [BPProductModel]
    func fetchReviews() -> [BPReviewModel]
}

final class BPContentCellService: BPContentCellServiceProtocol {
    func fetchProducts() -> [BPProductModel] {
        return BPProductModel.fetch()
    }
    
    func fetchReviews() -> [BPReviewModel] {
        return BPReviewModel.fetch()
    }
}
