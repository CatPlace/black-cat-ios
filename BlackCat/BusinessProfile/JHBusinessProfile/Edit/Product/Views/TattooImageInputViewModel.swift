//
//  TattooImageInputViewModel.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/21.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay
import BlackCatSDK

class TattooImageInputViewModel {
    // MARK: - Input
    let imageDataListRelay: BehaviorRelay<[Data?]>
    
    // MARK: - Output
    let cellViewModelsDrvier: Driver<[Data?]>
    let countLimitLabelTextDriver: Driver<String>
    
    init(imageDataList: [Data] = []) {
        var imageDataListInitialValue: Array<Data?> = .init(repeating: nil, count: 5)
        imageDataList.enumerated().forEach { index, data in
            imageDataListInitialValue[index] = data
        }
        
        imageDataListRelay = .init(value: imageDataListInitialValue)
        
        cellViewModelsDrvier = imageDataListRelay
            .asDriver(onErrorJustReturn: [])
        
        countLimitLabelTextDriver = imageDataListRelay
            .map { "(\($0.compactMap { $0 }.count)/\(5))" }
            .asDriver(onErrorJustReturn: "")
        
    }
}
