//
//  MagazineTestUseCase.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/06.
//

import Foundation
import RxSwift
class MagazineTestUseCase {
    
    func loadMoreMagazine(page: Int) -> Observable<[PreviewMagazine]> {
        print("request page: \(page)")
        return .just(PreviewMagazine.dummy)
    }
    
    func loadFamousMagazine() -> Observable<[FamousMagazine]> {
        return .just(FamousMagazine.dummy)
    }
}
