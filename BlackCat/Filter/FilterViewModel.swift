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
    
    // MARK: - Output
    let taskDriver: Driver<[String]>
    let locationDriver: Driver<[String]>
    
    // MARK: - Initialize
    init() {
        let tasks = FilterTask.allCases
            .map { $0.rawValue }
        
        taskDriver = Observable.just(tasks)
            .asDriver(onErrorJustReturn: [])
        
        let loactions = FilterLoaction.allCases
            .map { $0.rawValue }
        locationDriver = Observable.just(loactions)
            .asDriver(onErrorJustReturn: [])
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
