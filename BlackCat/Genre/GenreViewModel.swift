//
//  GenreViewModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/21.
//

import Foundation

import BlackCatSDK
import RxCocoa
import RxSwift

enum GenreType: Int, CaseIterable {
    case 전체보기
    case 레터링
    case 미니타투
    case 감성타투
    case 이레즈미
    case 블랙그레이
    case 라인워크
    case 헤나
    case 커버업
    case 뉴스쿨
    case 올드스쿨
    case 잉크스플래쉬
    case 치카노
    case 컬러
    case 캐릭터

    static var allGenre: [GenreType] { GenreType.allCases }

    var title: String {
        switch self {
        case .전체보기: return "전체보기"
        case .레터링: return "레터링"
        case .미니타투: return "미니 타투"
        case .감성타투: return "감성 타투"
        case .이레즈미: return "이레즈미"
        case .블랙그레이: return "블랙&그레이"
        case .라인워크: return "라인워크"
        case .헤나: return "헤나"
        case .커버업: return "커버업"
        case .뉴스쿨: return "뉴스쿨"
        case .올드스쿨: return "올드스쿨"
        case .잉크스플래쉬: return "잉크 스플래쉬"
        case .치카노: return "치카노"
        case .컬러: return "컬러"
        case .캐릭터: return "캐릭터"
        }
    }

    static func id(_ title: String) -> Int {
        allGenre.firstIndex { $0.title == title } ?? 0
    }
}

class GenreViewModel {

    let disposeBag = DisposeBag()
    var genreTitle: String

    // MARK: - Input

    private let categoryList = Observable<[String]>.just(["전체보기", "레터링", "미니 타투", "감성 타투", "이레즈미", "블랙&그레이", "라인워크", "헤나", "커버업", "뉴스쿨", "올드스쿨", "잉크 스플래쉬", "치카노", "컬러", "캐릭터"])
    let viewWillAppear = PublishRelay<Void>()
    let filterViewDidDismiss = PublishRelay<Void>()
    let selectedDropDownItemRow = PublishRelay<Int>()

    // MARK: - Output

    let dropDownItems: Driver<[String]>
    // Home에서도 사용하는 Cell이라 Common으로 이동할 필요가 있어 보입니다.
    let categoryItems: Driver<[CommonFullImageCellViewModel]>

    init(genreTitle: String) {
        self.genreTitle = genreTitle

        let filterService = FilterService()

        let filteredTask = filterViewDidDismiss
            .flatMap { filterService.taskService.fetch()
                .map { $0.filter { $0.isSubscribe == true } } }

        let filteredLocation = filterViewDidDismiss
            .flatMap { filterService.locationService.fetch()
                .map { $0.filter { $0.isSubscribe == true } } }

        let filteredInfo = Observable.zip(filteredTask, filteredLocation)

        let changedGenreTitle = selectedDropDownItemRow
            .do { print($0) }
            .map { row in GenreType(rawValue: row)?.title ?? "전체보기" }

        let newGenreTitle = Observable.merge([
            Observable.just(genreTitle),
            changedGenreTitle
        ])
            .do { print("new Title", $0) }

        let fetchedItems = Observable.merge([
            viewWillAppear.asObservable(),
            filterViewDidDismiss.asObservable(),
            selectedDropDownItemRow.map { _ in () }.asObservable()
        ])
            .withLatestFrom(newGenreTitle) { $1 }
            .flatMap { CatSDKNetworkTattoo.rx.fetchTattosInSpecificCategory(categoryID: GenreType.id($0)) }
            .withLatestFrom(filteredInfo) { tattoos, filteredInfo in
                return tattoos.filter { tattoo in
                    filteredInfo.1.contains { $0.type.rawValue == tattoo.address }
                }
            }

        dropDownItems = viewWillAppear
            .withLatestFrom(categoryList)
            .asDriver(onErrorJustReturn: [])

        categoryItems = fetchedItems
            .map { tattoos in
                return tattoos.map { tattoo -> CommonFullImageCellViewModel in
                    if let imageURLString = tattoo.imageURLStrings.first {
                        return CommonFullImageCellViewModel(imageURLString: imageURLString)
                    } else {
                        return CommonFullImageCellViewModel(imageURLString: nil)
                    }
                }
            }
            .asDriver(onErrorJustReturn: [])
    }
}
