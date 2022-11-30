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

struct MagazineViewModel {
    
    typealias offsetX = CGFloat
    typealias offsetY = CGFloat
    typealias screenWidth = CGFloat
    typealias screenHeight = CGFloat
    
    var useCase: MagazineTestUseCase
    
    // MARK: - Input
    let updateMagazineTrigger = BehaviorRelay<Void>(value: ())
    let recentMagazineSectionScrollOffsetX = PublishRelay<(offsetX, screenWidth)>() // (offsetX, view넓이)
    let magazineCollectionViewScrollOffsetY = PublishRelay<(offsetY, screenHeight)>() // (offsetY, view높이)
    
    // MARK: - Output
    var magazineDriver: Driver<[MagazineSection]>
    var recentSectionPageControlValuesDriver: Driver<(Int, Int)> // (numberOfPages, currentPage)
    var magazineCollectionViewTopInsetDriver: Driver<CGFloat>
    var magazineCollectionViewScrollOffsetYDriver: Driver<CGFloat>
    
    init(useCase: MagazineTestUseCase = MagazineTestUseCase()) {
        self.useCase = useCase
        
        let fetchedData = updateMagazineTrigger
            .scan(0) { prePage, _ in prePage + 1 }
            .flatMap { useCase.loadMoreMagazine(page: $0) }
            .scan(into: [Magazine]()) { feeds, item in feeds.append(contentsOf: item) }
            .share()
        
        let recentMagazineSize = 4
        
        let recentMagazineSectionItemsObservable = fetchedData
            .map { Array($0[..<recentMagazineSize]) }
        
        let lastMagazineSectionItemsObservable = fetchedData
            .map { Array($0[recentMagazineSize...]) }
        
        self.magazineDriver = Observable
            .combineLatest(recentMagazineSectionItemsObservable,
                           lastMagazineSectionItemsObservable) { topSectionItems, lastStorSectionItems in
                return [
                    MagazineSection(items: topSectionItems.map { .topSection(.init(magazine: $0)) }),
                    MagazineSection(items: lastStorSectionItems.map { .lastStorySection(.init(magazine: $0)) })
                ]
            }.asDriver(onErrorJustReturn: [])
        
        recentSectionPageControlValuesDriver = recentMagazineSectionScrollOffsetX
            .map { (offsetX, screenWidth) in (recentMagazineSize, Int(round(offsetX / screenWidth))) }
            .asDriver(onErrorJustReturn: (0, 0))
        
        magazineCollectionViewTopInsetDriver = magazineCollectionViewScrollOffsetY
            .map { (offsetY, screenHeight) in
                offsetY > screenHeight
                ? 26.0
                : 0.0
            }.distinctUntilChanged()
            .asDriver(onErrorJustReturn: 0.0)
        
        magazineCollectionViewScrollOffsetYDriver = magazineCollectionViewScrollOffsetY
            .map { $0.0 }.asDriver(onErrorJustReturn: 0.0)
    }
}
