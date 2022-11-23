//
//  MyPageModel.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/24.
//

import Foundation

struct User {
    let jwt: String
    let name: String
    let imageUrl: String
}

struct Tattoo {
    let imageUrl: String // imgUrl or UIImage?
    let title: String
    let userName: String
    let price: Int
}
