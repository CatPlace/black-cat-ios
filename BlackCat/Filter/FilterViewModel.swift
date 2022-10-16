//
//  FilterViewModel.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/16.
//

import UIKit
import RxSwift
import RxCocoa

class FilterViewModel {
    
    // MARK: - Input
    let taskItemSelectedSubject = PublishSubject<IndexPath>()
    
    // MARK: - Output
    let taskDriver: Driver<[FilterTask]>
    let locationDriver: Driver<[FilterLocation]>
    
//    let taskItemReloadDriver: Driver<IndexPath>
    // MARK: - Initialize
    init() {
        let tasks = FilterTaskType.allCases
            .map { item -> FilterTask in
                FilterTask(item: item, isSubscribe: false)
            }
        
        taskDriver = Observable.just(tasks)
            .asDriver(onErrorJustReturn: [])
        
        let loactions = FilterLocationType.allCases
            .map { item -> FilterLocation in
                FilterLocation(item: item, isSubscribe: false)
            }
        locationDriver = Observable.just(loactions)
            .asDriver(onErrorJustReturn: [])
        
//        taskItemReloadDriver = taskItemSelectedSubject
//            .map(<#T##transform: (IndexPath) throws -> Result##(IndexPath) throws -> Result#>)
        
    }
    
    // MARK: - function
    // 구분선 Modifier
    func divierViewModifier(_ sender: UIView) {
        sender.backgroundColor = .darkGray
    }
    
    // 섹션 타이틀 Modifier
    func sectionTitleModifier(_ sender: UILabel) {
        sender.textAlignment = .center
        sender.textColor = .gray
        sender.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
    }
    
    
}
