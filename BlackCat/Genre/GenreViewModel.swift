//
//  GenreViewModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/21.
//

import Foundation

import RxCocoa
import RxSwift

class GenreViewModel {

    // MARK: - Input

    private let categoryList = Observable<[String]>.just(["전체보기", "미니 타투", "감성 타투", "이레즈미", "블랙&그레이", "라인워크", "헤나", "커버업", "뉴스쿨", "올드스쿨", "잉크 스플래쉬", "치카노", "컬러", "캐릭터", "이건 좀 길다 조심해라 말했다"])
    let viewWillAppear = PublishRelay<Void>()
    let selectedDropDownItemRow = PublishRelay<Int>()

    // MARK: - Output

    let dropDownList: Driver<[String]>

    init() {
        dropDownList = viewWillAppear
            .withLatestFrom(categoryList)
            .asDriver(onErrorJustReturn: [])
    }
}
