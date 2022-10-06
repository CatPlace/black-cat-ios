//
//  MagazineViewModel.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/05.
//

import Foundation

import RxSwift
import RxRelay
import RxCocoa

struct FamousMagazine {
    let imageUrl: String
}

struct PreviewMagazine {
    let imageUrl: String
    let title: String
    let writer: String
    let date: String
}

struct MagazineSection {
    var items: [Item]
}

enum MagazineItem {
    case MagazineFamousCellItem([FamousMagazine])
    case MagazinePreviewCellItem([PreviewMagazine])
}

struct MagazineViewModel {

    var useCase: MagazineTestUseCase
    
    //input
    var updateTrigger = BehaviorRelay<Int>(value: 0)
    
    //output
    var magazineFamousCellItems: Observable<[FamousMagazine]>
    var magazinePreviewCellItems: Observable<[PreviewMagazine]>
    var combinedMagazinePreviewCellItems: Observable<[PreviewMagazine]>
    var fetchedMagazineItems: Observable<[MagazineSection]>
    
    init(useCase: MagazineTestUseCase = MagazineTestUseCase()) {
        self.useCase = useCase
        
        // 첫 섹션 fetch
        magazineFamousCellItems = updateTrigger
            .filter { page in page == 0 }
            .flatMap { _ in useCase.loadFamousMagazine() }
        
        // 두번째 섹션 page fetch
        magazinePreviewCellItems = updateTrigger
            .scan(0, accumulator: { prePage, one in
                return prePage + one
            }).flatMap { page in useCase.loadMoreMagazine(page: page ) }
        
        // 두번째 섹션의 기존 아이템들과 새로운 page의 아이템을 합친다.
        combinedMagazinePreviewCellItems = magazinePreviewCellItems.scan(into: [PreviewMagazine]()) { feeds, item in
            feeds.append(contentsOf: item)
        }
        
        // 각 섹션에 업데이트가 발생하면 이벤트 생성
        // return 값: 각 섹션의 dataSource
        fetchedMagazineItems = Observable.combineLatest(magazineFamousCellItems, combinedMagazinePreviewCellItems) { famouseCell, previewCell in
            [
                MagazineSection(items: [MagazineItem.MagazineFamousCellItem(famouseCell.map {
                    .init(imageUrl: $0.imageUrl)
                })]),
                MagazineSection(items: [MagazineItem.MagazinePreviewCellItem(previewCell.map{
                    .init(imageUrl: $0.imageUrl, title: $0.title, writer: $0.writer, date: $0.date)
                })])
            ]
        }
    }
}
