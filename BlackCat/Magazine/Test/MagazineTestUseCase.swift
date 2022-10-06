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
        return .just(PreviewMagazine.dummy)
    }
    

    
}
