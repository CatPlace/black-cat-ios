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
   
    var cellDisplayingIndexRowRelay = PublishRelay<CGFloat>()
    
    var visibleCellIndexPath: Driver<Int>
    var sections: Driver<[JHBusinessProfileCellSection]>
    init(tattooistId: Int) {
        // TODO: - 유저 구분
        isOwner = tattooistId == CatSDKUser.user().id
        
        self.sections = .just(configurationSections())
        
        visibleCellIndexPath = cellDisplayingIndexRowRelay
            .distinctUntilChanged()
            .map { Int($0) }
            .asDriver(onErrorJustReturn: 0)
        
        func configurationSections() -> [JHBusinessProfileCellSection] {
            
            let thumbnailCell: JHBusinessProfileItem = .thumbnailImageItem(.init())
            
            let thumbnailSection = JHBusinessProfileCellSection.thumbnailImageCell([thumbnailCell])
            
            let contentProfile: JHBusinessProfileItem = .contentItem(.init(contentModel: .init(order: 0), profile: "a", products: ["ba"], priceInfo: "c"))
            let contentProduct: JHBusinessProfileItem = .contentItem(.init(contentModel: .init(order: 1), profile: "1", products: ["22", "2"], priceInfo: "3"))
            let contentPriceInfo: JHBusinessProfileItem = .contentItem(.init(contentModel: .init(order: 2), profile: "x", products: ["yy", "y", "Y"], priceInfo: "z"))
            
            let contentSection = JHBusinessProfileCellSection.contentCell([contentProfile, contentProduct, contentPriceInfo])
            
            return [thumbnailSection, contentSection]
        }
    }
    
}

//struct JHBPSectionFactory {
//
//    static func makeThumbnailCell() -> JHBusinessProfileItem {
//        return JHBusinessProfileItem.thumbnailImageItem(.init())
//    }
//
//    static func makeContentCell(order: Int) -> JHBusinessProfileItem {
//        let item = BPContentModel(order: order)
//
//        return JHBusinessProfileItem.contentItem(.init(contentModel: item))
//    }
//}

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
