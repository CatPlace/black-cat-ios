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
    var currentDeleteProductIndexList: [Int] = []
    let headerViewModel: JHBPContentSectionHeaderViewModel = .init()
    typealias TattooId = Int
    
    // MARK: - Inputs
    let cellWillAppear = PublishRelay<CGFloat>()
    let cellDidAppear = PublishRelay<CGFloat>()
    let viewWillAppear = PublishRelay<Void>()
    let viewDidAppear = PublishRelay<Void>()
    let selectedTattooIndex = PublishRelay<Int>()
    let deleteProductTrigger = PublishRelay<[Int]>()
    let deleteCompleteRelay = PublishRelay<Void>()
    
    // MARK: - Outputs
    let visibleCellIndexPath: Driver<Int>
    let sections: Driver<[JHBusinessProfileCellSection]>
    let showTattooDetail: Driver<TattooId>
    let scrollToTypeDriver: Driver<JHBPContentHeaderButtonType>
    let initEditModeDriver: Driver<Void>
    let deleteSuccessDriver: Driver<Void>
    let deleteFailDriver: Driver<Void>
    
    init(tattooistId: Int) {
        // TODO: - 유저 구분
        isOwner = tattooistId == CatSDKUser.user().id

        let localTattooistInfo = Observable.merge([viewWillAppear.asObservable(), deleteCompleteRelay.asObservable()])
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
        
        let currentTattooistInfo = Observable.merge([localTattooistInfo.filter { $0 != .empty }, fetchedTattooistInfo]).share()
        
        sections = currentTattooistInfo
            .map { configurationSections(
                imageUrlString: $0.introduce.imageUrlString ?? "",
                profileDescription: $0.introduce.introduce,
                products: $0.tattoos,
                priceInformation: $0.estimate.description
            ) }
            .asDriver(onErrorJustReturn: [])
        
        visibleCellIndexPath = cellWillAppear
            .map { Int($0) }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: 0)
        
        showTattooDetail = selectedTattooIndex
            .map { UserDefaultManager.getTattooistInfo().tattoos[$0].tattooId }
            .asDriver(onErrorJustReturn: 0)
        
        scrollToTypeDriver = viewWillAppear
            .withLatestFrom(visibleCellIndexPath)
            .compactMap { .init(rawValue: $0) }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .product)
        
        let deleteReuslt = deleteProductTrigger.withLatestFrom(currentTattooistInfo) { (index: $0, tattooist: $1) }
            .map { indexList, tattooist in
                indexList.map { tattooist.tattoos[$0].tattooId }
            }.flatMap { CatSDKTattooist.deleteTattoo(tattooIds: $0) }
            .share()
            
        let deleteSuccess = deleteReuslt.filter { $0.0 == $0.1 }
        // TODO: - 에러 처리
        let deleteFail = deleteReuslt.filter { $0.0 != $0.1 }
        
        deleteSuccessDriver = deleteSuccess
            .withLatestFrom(deleteProductTrigger)
            .map { ids in
                var userInfo = CatSDKTattooist.localTattooistInfo()
                userInfo.tattoos.remove(atOffsets: IndexSet(ids))
                return CatSDKTattooist.updateLocalTattooistInfo(tattooistInfo: userInfo)
            }.asDriver(onErrorJustReturn: ())
        
        deleteFailDriver = deleteFail.map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        func configurationSections(imageUrlString: String, profileDescription: String, products: [Model.TattooThumbnail], priceInformation: String) -> [JHBusinessProfileCellSection] {
            
            let thumbnailCell: JHBusinessProfileItem = .thumbnailImageItem(.init(imageUrlString: imageUrlString))
            
            let thumbnailSection = JHBusinessProfileCellSection.thumbnailImageCell([thumbnailCell])
            
            let contentProfile: JHBusinessProfileItem = .contentItem(.init(contentModel: .init(order: 0), profile: profileDescription, products: [], priceInfo: ""))
            let contentProductCellViewModel: JHBPContentCellViewModel = .init(contentModel: .init(order: 1),
                                                    profile: "",
                                                    products: products,
                                                    priceInfo: "")
            
            let contentProduct: JHBusinessProfileItem = .contentItem(contentProductCellViewModel)
                                                                     
            let contentPriceInfo: JHBusinessProfileItem = .contentItem(.init(contentModel: .init(order: 2), profile: "", products: [], priceInfo: priceInformation))
            
            let contentSection = JHBusinessProfileCellSection.contentCell([contentProfile, contentProduct, contentPriceInfo])
            
            return [thumbnailSection, contentSection]
        }
        
        initEditModeDriver = cellWillAppear
            .distinctUntilChanged()
            .filter { $0 != 1 }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
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
