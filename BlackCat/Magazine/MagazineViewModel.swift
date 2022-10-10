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
    
    var useCase: MagazineTestUseCase
    
    // MARK: - Input
    let updateMagazineTrigger = BehaviorRelay<Int>(value: 0)
    let recentMagazineSectionScrollOffsetX = PublishRelay<(CGFloat, CGFloat)>() // (offsetX, view넓이)
    let magazineCollectionViewScrollOffsetY = PublishRelay<(CGFloat, CGFloat)>() // (offsetY, view높이)
    
    // MARK: - Output
    var magazineDriver: Driver<[MagazineSection]>
    var recentSectionPageControlValuesDriver: Driver<(Int, Int)> // (numberOfPages, currentPage)
    var magazineCollectionViewTopInsetDriver: Driver<CGFloat>
    var magazineCollectionViewScrollOffsetYDriver: Driver<CGFloat>
    
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
        
        self.magazineDriver = Observable.combineLatest(recentMagazineSectionItemsObservable,
                                                       lastMagazineSectionItemsObservable)
        {
            topSectionItems,
            lastStorSectionItems in
            
            return [
                MagazineSection(items: topSectionItems.map { .topSection(.init(magazine: $0)) }),
                MagazineSection(items: lastStorSectionItems.map { .lastStorySection(.init(magazine: $0)) })
            ]
            
        }.asDriver(onErrorJustReturn: [])
        
        recentSectionPageControlValuesDriver = recentMagazineSectionScrollOffsetX
            .map { (offsetX, sceneWidth) in
                (recentMagazineSize, Int(round(offsetX / sceneWidth)))
            }
            .asDriver(onErrorJustReturn: (0, 0))
        
        magazineCollectionViewTopInsetDriver = magazineCollectionViewScrollOffsetY
            .map { (offsetY, sceneHeight) in
                offsetY > sceneHeight
                ? 26.0
                : 0.0
            }.distinctUntilChanged()
            .asDriver(onErrorJustReturn: 0.0)
        
        magazineCollectionViewScrollOffsetYDriver = magazineCollectionViewScrollOffsetY
            .map { (offsetY, _) in
                offsetY
            }.asDriver(onErrorJustReturn: 0.0)
    }
}
