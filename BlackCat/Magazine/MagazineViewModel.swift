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
    var updateMagazineTrigger = BehaviorRelay<Int>(value: 0)
    
    //output
    var magazineDriver: Driver<[MagazineSection]>
    init(useCase: MagazineTestUseCase = MagazineTestUseCase()) {
        self.useCase = useCase
        
        let fetchedData = updateMagazineTrigger
            .scan(0, accumulator: { prePage, one in
                prePage + one
            }).flatMap { page in useCase.loadMoreMagazine(page: page) }
            .scan(into: [Magazine]()) { feeds, item in
                feeds.append(contentsOf: item)
            }.share()
        
        let recentMagazineSectionItemsObservable = fetchedData
            .map { Array($0[...3]) }
        
        let lastMagazineSectionItemsObservable = fetchedData
            .map { Array($0[4...]) }
        
        self.magazineDriver = Observable.combineLatest(recentMagazineSectionItemsObservable, lastMagazineSectionItemsObservable) { topSectionItems, lastStorSectionItems in
            [
                MagazineSection(items: topSectionItems.map { .topSection(.init(magazine: $0)) }),
                MagazineSection(items: lastStorSectionItems.map { .lastStorySection(.init(magazine: $0)) })
            ]
        }.asDriver(onErrorJustReturn: [])
    }
}
