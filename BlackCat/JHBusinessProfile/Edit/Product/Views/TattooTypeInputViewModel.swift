//
//  TattooTypeInputViewModel.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/25.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay
import BlackCatSDK

class TattooTypeInputViewModel {
    let tattooTypeRelay: BehaviorRelay<TattooType?>
    
    let cellViewModelsDriver: Driver<[FilterCellViewModel]>
    
    init(tattooType: TattooType?) {
        tattooTypeRelay = .init(value: tattooType)
        
        cellViewModelsDriver = tattooTypeRelay.map { type in
            TattooType.allCases.map { FilterCellViewModel(color: .white, typeString: $0.title(), isSubscribe: type == $0) }
        }
        .asDriver(onErrorJustReturn: [])
    }
}
