//
//  BPContentCellService.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/31.
//

import Foundation

// MARK: - Service를 정의
protocol BPContentCellServiceProtocol {
    func fetchProfiles() -> [BPProfileModel]
    func fetchProducts() -> [BPProductModel]
    func fetchReviews() -> [BPReviewModel]
    func fetchPriceInfos() -> [BPPriceInfoModel]
}

final class BPContentCellService: BPContentCellServiceProtocol {
    func fetchProfiles() -> [BPProfileModel] {
        return BPProfileModel.fetch()
    }
    
    func fetchProducts() -> [BPProductModel] {
        return BPProductModel.fetch()
    }
    
    func fetchReviews() -> [BPReviewModel] {
        return BPReviewModel.fetch()
    }
    
    func fetchPriceInfos() -> [BPPriceInfoModel] {
        return BPPriceInfoModel.fetch()
    }
}
