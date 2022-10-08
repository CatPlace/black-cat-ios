//
//  MagazineViewModel.dummy.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/06.
//

import Foundation
extension FamousMagazine {
    
    static let dummy: [FamousMagazine] = [
        .init(id: 0, imageUrl: "https://i.imgur.com/faaRlPL.png"),
        .init(id: 1, imageUrl: "https://i.imgur.com/faaRlPL.png"),
        .init(id: 2, imageUrl: "https://i.imgur.com/faaRlPL.png"),
        .init(id: 3, imageUrl: "https://i.imgur.com/faaRlPL.png")
    ]
    
}

extension PreviewMagazine {
    
    static let dummy: [PreviewMagazine] = [
        .init(id: 0, imageUrl: "https://i.imgur.com/yiZCCf4.png", title: "제목", writer: "김타투", date: "2022.10.31"),
        .init(id: 1, imageUrl: "https://i.imgur.com/w3dLfvz.png", title: "제목", writer: "김타투", date: "2022.10.30"),
        .init(id: 2, imageUrl: "https://i.imgur.com/ZUfBXIO.png", title: "제목", writer: "김타투", date: "2022.10.29"),
        .init(id: 3, imageUrl: "https://i.imgur.com/bg3he4J.png", title: "제목", writer: "김타투", date: "2022.10.28"),
        .init(id: 4, imageUrl: "https://i.imgur.com/nhAtXYq.png", title: "제목", writer: "김타투", date: "2022.10.27"),
        .init(id: 5, imageUrl: "https://i.imgur.com/F3LmAmi.png", title: "제목", writer: "김타투", date: "2022.10.26"),
        .init(id: 6, imageUrl: "https://i.imgur.com/PnG2FTP.png", title: "제목", writer: "김타투", date: "2022.10.25"),
        .init(id: 7, imageUrl: "https://i.imgur.com/1ABD0Gy.png", title: "제목", writer: "김타투", date: "2022.10.24"),
    ]
    
}
