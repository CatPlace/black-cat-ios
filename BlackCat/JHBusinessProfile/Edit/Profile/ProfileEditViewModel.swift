//
//  ProfileEditViewModel.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class ProfileEditViewModel {
    var imageRelay: BehaviorRelay<Any?> // Data or urlString
    var imageDriver: Driver<UIImage?>
    init() {
        imageRelay = .init(value: "https://www.chemicalnews.co.kr/news/photo/202106/3636_10174_4958.jpg")

        imageDriver = imageRelay
            .flatMap(UIImage.convertToUIImage)
            .asDriver(onErrorJustReturn: UIImage(systemName: "trash"))
    }
}
