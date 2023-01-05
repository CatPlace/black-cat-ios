//
//  MyPageTestUseCase.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/24.
//

import Foundation
import RxSwift
import BlackCatSDK

class MyPageUseCase {
    func userProfile() -> Observable<Model.User> {
        return .just(.init(id: -1, jwt: "text", name: "김타투", imageUrl: "https://cdn.eyesmag.com/content/uploads/posts/2022/08/08/main-ad65ae47-5a50-456d-a41f-528b63071b7b.jpg"))
    }
}
