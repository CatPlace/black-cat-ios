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

enum TattooType: String, CaseIterable {
    case work = "WORK"
    case design = "DESIGN"

    func title() -> String {
        switch self {
        case .work:
            return "사진"
        case .design:
            return "도안"
        }
    }
}

class TattooTypeInputViewModel {
    let tattooTypeRelay: BehaviorRelay<TattooType?>
    
    let cellViewModelsDriver: Driver<[FilterCellViewModel]>
    
    init(tattooType: String?) {
        tattooTypeRelay = .init(value: .init(rawValue: tattooType ?? ""))
        
        cellViewModelsDriver = tattooTypeRelay.map { type in
            TattooType.allCases.map { FilterCellViewModel(typeString: $0.title(), isSubscribe: type == $0) }
        }
        .asDriver(onErrorJustReturn: [])
    }
}
