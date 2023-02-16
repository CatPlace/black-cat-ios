//
//  JHBusinessProfileViewModel.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/12/28.
//
import Foundation

import RxSwift
import RxCocoa
import RxRelay
import RxDataSources
import BlackCatSDK

final class JHBusinessProfileViewModel {
    let isOwner: Bool
    
    typealias TattooId = Int
    
    // MARK: - Inputs
    var cellDisplayingIndexRowRelay = PublishRelay<CGFloat>()
    var viewWillAppear = PublishRelay<Bool>()
    var viewDidAppear = PublishRelay<Bool>()
    var selectedTattooIndex = PublishRelay<Int>()
    
    // MARK: - Outputs
    var visibleCellIndexPath: Driver<Int>
    var sections: Driver<[JHBusinessProfileCellSection]>
    var showTattooDetail: Driver<TattooId>
    var scrollToTypeDriver: Driver<JHBPContentHeaderButtonType>
    
    init(tattooistId: Int) {
        // TODO: - 유저 구분
        isOwner = tattooistId == CatSDKUser.user().id

        let localTattooistInfo = viewWillAppear
            .map { _ in CatSDKTattooist.localTattooistInfo() }
        
        let fetchedTattooistInfo = localTattooistInfo
            .filter { $0 == .empty }
            .flatMap { _ in
                let fetchedProfileData = CatSDKTattooist.profile(tattooistId: tattooistId).share()
                let fetchedProductsData = CatSDKTattooist.products(tattooistId: tattooistId).share()
                let fetchedPriceInfoData = CatSDKTattooist.priceInfo(tattooistId: tattooistId).share()
                return Observable.combineLatest(fetchedProfileData, fetchedProductsData, fetchedPriceInfoData) {
                    Model.TattooistInfo(introduce: $0, tattoos: $1, estimate: $2)
                }.do { CatSDKTattooist.updateLocalTattooistInfo(tattooistInfo: $0) }
            }.share()
        
        sections = Observable.merge([localTattooistInfo.filter { $0 != .empty }, fetchedTattooistInfo])
            .map { configurationSections(
                imageUrlString: $0.introduce.imageUrlString ?? "",
                profileDescription: $0.introduce.introduce,
                products: $0.tattoos,
                priceInformation: $0.estimate.description
            ) }
            .asDriver(onErrorJustReturn: [])
        
        visibleCellIndexPath = cellDisplayingIndexRowRelay
            .distinctUntilChanged()
            .map { Int($0) }
            .asDriver(onErrorJustReturn: 0)
        
        showTattooDetail = selectedTattooIndex
            .map { UserDefaultManager.getTattooistInfo().tattoos[$0].tattooId }
            .asDriver(onErrorJustReturn: 0)
        
        scrollToTypeDriver = viewDidAppear
            .map { _ in .product }
            .asDriver(onErrorJustReturn: .product)
        
        func configurationSections(imageUrlString: String, profileDescription: String, products: [Model.TattooThumbnail], priceInformation: String) -> [JHBusinessProfileCellSection] {
            
            let thumbnailCell: JHBusinessProfileItem = .thumbnailImageItem(.init(imageUrlString: imageUrlString))
            
            let thumbnailSection = JHBusinessProfileCellSection.thumbnailImageCell([thumbnailCell])
            
            let contentProfile: JHBusinessProfileItem = .contentItem(.init(contentModel: .init(order: 0), profile: profileDescription, products: [], priceInfo: ""))
            let contentProduct: JHBusinessProfileItem = .contentItem(.init(contentModel: .init(order: 1),
                                                                           profile: "",
                                                                           products: products,
                                                                           priceInfo: ""))
                                                                     
                                                                     
            let contentPriceInfo: JHBusinessProfileItem = .contentItem(.init(contentModel: .init(order: 2), profile: "", products: [], priceInfo: priceInformation))
            
            let contentSection = JHBusinessProfileCellSection.contentCell([contentProfile, contentProduct, contentPriceInfo])
            
            return [thumbnailSection, contentSection]
        }
    }
    
}

enum JHBusinessProfileItem: Equatable, IdentifiableType {
    var identity: some Hashable { UUID().uuidString }
    
    case thumbnailImageItem(JHBPThumbnailImageCellViewModel)
    case contentItem(JHBPContentCellViewModel)
    
    static func == (lhs: JHBusinessProfileItem, rhs: JHBusinessProfileItem) -> Bool {
        lhs.identity == rhs.identity
    }
}

enum JHBusinessProfileCellSection {
    case thumbnailImageCell([JHBusinessProfileItem])
    case contentCell([JHBusinessProfileItem])
}

extension JHBusinessProfileCellSection: AnimatableSectionModelType {
    var identity: String { UUID().uuidString }
    
    typealias Item = JHBusinessProfileItem
    
    var items: [Item] {
        switch self {
        case .thumbnailImageCell(let items): return items
        case .contentCell(let items): return items
        }
    }
    
    init(original: JHBusinessProfileCellSection, items: [JHBusinessProfileItem]) {
        switch original {
        case .thumbnailImageCell: self = .thumbnailImageCell(items)
        case .contentCell: self = .contentCell(items)
        }
    }
}
