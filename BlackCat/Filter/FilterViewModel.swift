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
    
    // MARK: - Initialize
    init() {
        taskDriver = Observable.just(["작업", "도안"])
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
        sender.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
}
