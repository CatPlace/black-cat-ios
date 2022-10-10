//
//  MagazineTestUseCase.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/06.
//

import Foundation

import RxSwift

class MagazineTestUseCase {
    func loadMoreMagazine(page: Int) -> Observable<[Magazine]> {
        print("request page: \(page)")
        return .just(Magazine.dummy.map { magazine in
            Magazine(
                id: magazine.id + (page * Magazine.dummy.count),
                imageUrl: magazine.imageUrl,
                title: magazine.title,
                writer: magazine.writer,
                date: magazine.date
            )
        })
    }
    
}
