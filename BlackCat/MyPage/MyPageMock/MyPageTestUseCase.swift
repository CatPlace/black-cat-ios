//
//  MyPageTestUseCase.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/24.
//

import Foundation
import RxSwift
class MyPageUseCase {
    func userProfile() -> Observable<User> {
        return .just(.init(jwt: "afgad", name: "김타투", imageUrl: "https://cdn.eyesmag.com/content/uploads/posts/2022/08/08/main-ad65ae47-5a50-456d-a41f-528b63071b7b.jpg"))
    }
    
    func recentTattoo() -> Observable<[Tattoo]> {
        return .just([
            .init(imageUrl: "A", title: "A", userName: "A", price: 1),
            .init(imageUrl: "B", title: "B", userName: "B", price: 2),
            .init(imageUrl: "C", title: "C", userName: "C", price: 3),
            .init(imageUrl: "D", title: "D", userName: "D", price: 4),
            .init(imageUrl: "E", title: "E", userName: "E", price: 5),
            .init(imageUrl: "F", title: "F", userName: "F", price: 6),
            .init(imageUrl: "G", title: "G", userName: "G", price: 7),
        ])
    }
}
