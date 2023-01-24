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
            .flatMap(convertToUIImage)
            .asDriver(onErrorJustReturn: UIImage(systemName: "trash"))

        func convertToUIImage(_ sender: Any?) -> Observable<UIImage?> {
            if let data = sender as? Data {
                return .just(UIImage(data: data))
            } else if let string = sender as? String, let url = URL(string: string) {
                return URLSession.shared.rx.response(request: URLRequest(url: url)).map { UIImage(data: $1) }
            } else if let image = sender as? UIImage {
                return .just(image)
            }
            else {
                return .just(UIImage(systemName: "trash"))
            }
        }
    }
}
