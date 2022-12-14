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
final class JHBUsinessProfileViewModel {
    typealias Will = IndexPath
    typealias Did = IndexPath
    var sections: BehaviorRelay<[JHBusinessProfileCellSection]>
    var cellDisplayingIndexPathRelay = PublishRelay<(Will, Did)>()
    
    var visibleCellIndexPath: Driver<IndexPath>
    
    init(sections: BehaviorRelay<[JHBusinessProfileCellSection]> = .init(value: configurationSections())) {
        self.sections = sections
        let visibleCellIndex = cellDisplayingIndexPathRelay
            .filter { didEnd, will in return (didEnd != will) && (didEnd.section != 0) }
            .map { didEnd, will in return will }
    
        visibleCellIndexPath = visibleCellIndex
            .asDriver(onErrorJustReturn: .init(row: 0, section: 1))
    }
    
}
extension JHBUsinessProfileViewModel {
    static func configurationSections() -> [JHBusinessProfileCellSection] {
        
        let thumbnailCell = JHBPSectionFactory.makeThumbnailCell()
        let thumbnailSection = JHBusinessProfileCellSection.thumbnailImageCell([thumbnailCell])
        
        let contentProfile = JHBPSectionFactory.makeContentCell(order: 0)
        let contentProduct = JHBPSectionFactory.makeContentCell(order: 1)
        
        let contentSection = JHBusinessProfileCellSection.contentCell([contentProfile, contentProduct])
        
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
