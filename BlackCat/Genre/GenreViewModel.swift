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

    private let categoryList = Observable<[String]>.just(["전체보기", "미니 타투", "감성 타투", "이레즈미", "블랙&그레이", "라인워크", "헤나", "커버업", "뉴스쿨", "올드스쿨", "잉크 스플래쉬", "치카노", "컬러", "캐릭터"])
    let viewWillAppear = PublishRelay<Void>()
    let selectedDropDownItemRow = PublishRelay<Int>()

    // MARK: - Output

    let dropDownItems: Driver<[String]>
    // Home에서도 사용하는 Cell이라 Common으로 이동할 필요가 있어 보입니다.
    let categoryItems: Driver<[CommonFullImageCellViewModel]>

    init() {
        dropDownItems = viewWillAppear
            .withLatestFrom(categoryList)
            .asDriver(onErrorJustReturn: [])

        categoryItems = viewWillAppear
            .map { _ in Array(repeating: CommonFullImageCellViewModel(imageURLString: ""), count: 30) }
            .asDriver(onErrorJustReturn: [])
    }
}
