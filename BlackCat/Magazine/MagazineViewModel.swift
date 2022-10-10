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

struct Magazine {
    let id: Int
    let imageUrl: String
    let title: String
    let writer: String
    let date: String
}

struct MagazineSection {
    var items: [Item]
}

enum MagazineItem {
    case topSection(RecentMagazineCellViewModel)
    case lastStorySection(LastMagazineCellViewModel)
}

struct MagazineViewModel {
    
    var useCase: MagazineTestUseCase
    
    //input
    let updateMagazineTrigger = BehaviorRelay<Int>(value: 0)
    let scrollOffset = PublishRelay<CGFloat>()
    let recentSectionScrollOffsetX = PublishRelay<(CGFloat, CGFloat)>()
    
    //output
    var magazineDriver: Driver<[MagazineSection]>
    var recentSectionNumberOfPagesDriver: Driver<Int>
    var recentSectionCurrentPageDriver: Driver<Int>
    
    init(useCase: MagazineTestUseCase = MagazineTestUseCase()) {
        self.useCase = useCase
        
        let fetchedData = updateMagazineTrigger
            .scan(0, accumulator: { prePage, one in
                prePage + one
            }).flatMap { page in useCase.loadMoreMagazine(page: page) }
            .scan(into: [Magazine]()) { feeds, item in
                feeds.append(contentsOf: item)
            }.share()
        
        let recentMagazineSize = 4
        
        let recentMagazineSectionItemsObservable = fetchedData
            .map { Array($0[..<recentMagazineSize]) }
        
        let lastMagazineSectionItemsObservable = fetchedData
            .map { Array($0[recentMagazineSize...]) }
        
        self.magazineDriver = Observable.combineLatest(recentMagazineSectionItemsObservable, lastMagazineSectionItemsObservable) { topSectionItems, lastStorSectionItems in
            [
                MagazineSection(items: topSectionItems.map { .topSection(.init(magazine: $0)) }),
                MagazineSection(items: lastStorSectionItems.map { .lastStorySection(.init(magazine: $0)) })
            ]
        }.asDriver(onErrorJustReturn: [])
        
        recentSectionNumberOfPagesDriver = Observable.just(recentMagazineSize).asDriver(onErrorJustReturn: 0)
        
        recentSectionCurrentPageDriver = recentSectionScrollOffsetX
            .map { (offsetX, sceneWidth) in
            Int(round(offsetX / sceneWidth))
        }.distinctUntilChanged()
            .asDriver(onErrorJustReturn: 0)
    }
}
