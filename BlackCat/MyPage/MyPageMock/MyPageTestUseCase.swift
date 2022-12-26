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
    
    func recentTattoo() -> Observable<[Tattoo]> {
        return .just([
            .init(imageUrl: "https://ichef.bbci.co.uk/news/640/cpsprodpb/E172/production/_126241775_getty_cats.png", title: "A", userName: "A"),
            .init(imageUrl: "https://www.chemicalnews.co.kr/news/photo/202106/3636_10174_4958.jpg", title: "B", userName: "B"),
            .init(imageUrl: "https://src.hidoc.co.kr/image/lib/2022/5/12/1652337370806_0.jpg", title: "C", userName: "C"),
            .init(imageUrl: "https://cdn.eyesmag.com/content/uploads/posts/2022/08/08/main-ad65ae47-5a50-456d-a41f-528b63071b7b.jpg", title: "D", userName: "D"),
            .init(imageUrl: "https://interbalance.org/wp-content/uploads/2021/08/ray-zhuang-Px2Y-sio6-c-unsplash-scaled.jpg", title: "E", userName: "E"),
            .init(imageUrl: "https://imagescdn.gettyimagesbank.com/500/202111/jv12508602.jpg", title: "F", userName: "F"),
            .init(imageUrl: "https://w.namu.la/s/71b52536288351fb16ba817939e2b4927dfcc41f50c898fd663f4419b21c009f444e20f3f150dc502909b104112bd877a159b512efdaa6df6c22425e9117a2284991f2bdc415ee05bc1c4b11d68c9e73871447f06a6194e50b3f23739b3e5efdbeedbad63478dca42858d0c07c30e02c", title: "G", userName: "G"),
        ])
    }
}
