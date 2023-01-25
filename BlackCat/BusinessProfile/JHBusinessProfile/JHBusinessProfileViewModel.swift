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

final class JHBUsinessProfileViewModel {
    let isOwner: Bool
    var sections: BehaviorRelay<[JHBusinessProfileCellSection]>
    var cellDisplayingIndexRowRelay = PublishRelay<CGFloat>()
    
    var visibleCellIndexPath: Driver<Int>
    
    init(sections: BehaviorRelay<[JHBusinessProfileCellSection]> = .init(value: configurationSections()),
         tattooistId: Int) {
        // TODO: - 유저 구분
        isOwner = tattooistId == CatSDKUser.user().id
        self.sections = sections
        
        
        visibleCellIndexPath = cellDisplayingIndexRowRelay
            .distinctUntilChanged()
            .map { Int($0) }
            .asDriver(onErrorJustReturn: 0)
        
        
    }
    
}
extension JHBUsinessProfileViewModel {
    static func configurationSections() -> [JHBusinessProfileCellSection] {
        
        let thumbnailCell = JHBPSectionFactory.makeThumbnailCell()
        let thumbnailSection = JHBusinessProfileCellSection.thumbnailImageCell([thumbnailCell])
        
        let contentProfile = JHBPSectionFactory.makeContentCell(order: 0)
        let contentProduct = JHBPSectionFactory.makeContentCell(order: 1)
        let contentPriceInfo = JHBPSectionFactory.makeContentCell(order: 2)
        
        let contentSection = JHBusinessProfileCellSection.contentCell([contentProfile, contentProduct, contentPriceInfo])
        
        return [thumbnailSection, contentSection]
    }
}

struct JHBPSectionFactory {
    
    static func makeThumbnailCell() -> JHBusinessProfileItem {
        let item = BPThumbnailModel(urlString: String.createRandomString(length: 5))
        
        return JHBusinessProfileItem.thumbnailImageItem(.init())
    }
    
    static func makeContentCell(order: Int) -> JHBusinessProfileItem {
        let item = BPContentModel(order: order)
        
        return JHBusinessProfileItem.contentItem(.init(contentModel: item))
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
