//
//  MagazineTestUseCase.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/06.
//

import Foundation

import RxSwift

class MagazineTestUseCase {
    
    func loadFamousMagazine() -> Observable<[FamousMagazine]> {
        print("update Famous Magazines")
        return .just(FamousMagazine.dummy)
    }
    
    func loadMoreMagazine(page: Int) -> Observable<[PreviewMagazine]> {
        print("request page: \(page)")
        return .just(PreviewMagazine.dummy.map { magazine in
            PreviewMagazine(
                id: magazine.id + (page * PreviewMagazine.dummy.count),
                imageUrl: magazine.imageUrl,
                title: magazine.title,
                writer: magazine.writer,
                date: magazine.date
            )
        })
    }
    
}
