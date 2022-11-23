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
        return .just(.init(jwt: "afgad", name: "김타투", profileImageUrlString: "https://cdn.eyesmag.com/content/uploads/posts/2022/08/08/main-ad65ae47-5a50-456d-a41f-528b63071b7b.jpg"))
    }
    
    func recentTattoo() -> Observable<[Tattoo]> {
        return .just([
            .init(imageUrl: "ㅁㄴㅇ", title: "타투 제목", userName: "김타투", price: 700000),
            .init(imageUrl: "ㅁ", title: "타투 제목", userName: "김타투", price: 1700000),
            .init(imageUrl: "ㄴ", title: "타투 제목", userName: "김타투", price: 2700000),
            .init(imageUrl: "ㄴ", title: "타투 제목", userName: "김타투", price: 2700000),
            .init(imageUrl: "ㄴ", title: "타투 제목", userName: "김타투", price: 2700000),
            .init(imageUrl: "ㄴ", title: "타투 제목", userName: "김타투", price: 2700000),
            .init(imageUrl: "ㄴ", title: "타투 제목", userName: "김타투", price: 2700000),
            .init(imageUrl: "ㄴ", title: "타투 제목", userName: "김타투", price: 2700000),
            .init(imageUrl: "ㄴ", title: "타투 제목", userName: "김타투", price: 2700000),
            .init(imageUrl: "ㄴ", title: "타투 제목", userName: "김타투", price: 2700000),
            .init(imageUrl: "ㄴ", title: "타투 제목", userName: "김타투", price: 2700000)
        ])
    }
}
