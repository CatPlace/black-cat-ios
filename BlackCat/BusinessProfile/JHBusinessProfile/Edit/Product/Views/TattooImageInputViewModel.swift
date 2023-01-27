//
//  TattooImageInputViewModel.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import BlackCatSDK

class TattooImageInputViewModel {
    // MARK: - Input
    let imageDataListRelay: BehaviorRelay<[Any]>
    
    // MARK: - Output
    let cellViewModelsDrvier: Driver<[Any?]>
    let countLimitLabelTextDriver: Driver<String>
    
    init() {
        imageDataListRelay = .init(value: [])
        cellViewModelsDrvier = imageDataListRelay
            .map(convertToViewImageList)
            .asDriver(onErrorJustReturn: [])
        
        countLimitLabelTextDriver = imageDataListRelay
            .map { "(\($0.compactMap { $0 }.count)/\(5))" }
            .asDriver(onErrorJustReturn: "")
        
        func convertToViewImageList(_ images: [Any]) -> [Any?] {
            var viewImageList: Array<Any?> = .init(repeating: nil, count: 5)
            images.enumerated().forEach { index, image in
                viewImageList[index] = image
            }
            return viewImageList
        }
        

    }
}
