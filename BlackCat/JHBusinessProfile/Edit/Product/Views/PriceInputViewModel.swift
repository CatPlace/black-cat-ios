//
//  PriceInputViewModel.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/03/07.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class PriceInputViewModel {
    // MARK: - Input
    let inputStringRelay: BehaviorRelay<String>
    let viewWillAppearRelay = PublishRelay<Void>()
    
    // MARK: - Output
    let titleDriver: Driver<String>
    let contentDriver: Driver<String>
    let placeholderDriver: Driver<String>
    let placeholderNSAttributedString: Driver<NSAttributedString>
    
    init(title: String = "가격", content: String? = nil, placeholder: String = "가격을 입력해주세요") {
        
        inputStringRelay = .init(value: content ?? "")
        
        titleDriver = .just(title)
        
        contentDriver = .just(content ?? "")
        
        placeholderDriver = .just(placeholder)
        
        placeholderNSAttributedString = placeholderDriver
            .map {
                NSAttributedString(string: $0,
                                      attributes: [
                                        .foregroundColor: UIColor.init(hex: "#999999FF"),
                                        .font: UIFont.appleSDGoithcFont(size: 12, style: .regular)
                                      ])
            }
    }
}
