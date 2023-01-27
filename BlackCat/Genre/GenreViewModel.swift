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
        case .미니타투: return "미니타투"
        case .감성타투: return "감성타투"
        case .이레즈미: return "이레즈미"
        case .블랙그레이: return "블랙&그레이"
        case .라인워크: return "라인워크"
        case .헤나: return "헤나"
        case .커버업: return "커버업"
        case .뉴스쿨: return "뉴스쿨"
        case .올드스쿨: return "올드스쿨"
        case .잉크스플래쉬: return "잉크스플래쉬"
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
    var genre: Model.Category

    // MARK: - Input

    private let genreList = Observable<[String]>.just(["전체보기", "레터링", "미니타투", "감성 타투", "이레즈미", "블랙&그레이", "라인워크", "헤나", "커버업", "뉴스쿨", "올드스쿨", "잉크 스플래쉬", "치카노", "컬러", "캐릭터"])
    let viewWillAppear = PublishRelay<Void>()
    let filterViewDidDismiss = PublishRelay<Void>()
    let selectedDropDownItemRow = PublishRelay<Int>()
    let didTapTattooItem = PublishRelay<Int>()

    // MARK: - Output

    let dropDownItems: Driver<[String]>
    // Home에서도 사용하는 Cell이라 Common으로 이동할 필요가 있어 보입니다.
    let genreItems: Driver<[CommonFullImageCellViewModel]>
    let pushToTattooDetailVC: Driver<TattooDetailViewModel>

    init(genre: Model.Category) {
        self.genre = genre

        let filterService = FilterService()

        let filteredTask = Observable.merge([
            viewWillAppear.asObservable(),
            filterViewDidDismiss.asObservable()
        ])
            .flatMap {
                filterService.taskService.fetch().map {
                    $0.filter { $0.isSubscribe == true }.map { $0.type.serverString() }
                }
            }

        let filteredLocation = Observable.merge([
            viewWillAppear.asObservable(),
            filterViewDidDismiss.asObservable()
        ])
            .flatMap {
                filterService.locationService.fetch().map {
                    $0.filter { $0.isSubscribe == true }.flatMap { $0.type.index() }
                }
            }

        let filteredInfo = Observable.zip(filteredTask, filteredLocation)

        let defaultGenreTitle = viewWillAppear
            .map { _ in genre.name }

        let changedGenreTitle = selectedDropDownItemRow
            .map { row in GenreType(rawValue: row)?.title ?? "전체보기" }

        let currentGenreTitle = Observable.merge([
            defaultGenreTitle,
            changedGenreTitle
        ])

        let fetchedItems = Observable.merge([
            viewWillAppear.asObservable(),
            filterViewDidDismiss.asObservable(),
            selectedDropDownItemRow.map { _ in () }.asObservable()
        ])
            .withLatestFrom(filteredInfo)
            .flatMap { filterInfo in
                // TODO: - 임시로 fist
                let tattoType = filterInfo.0.first
                let addressid = filterInfo.1.first
                if genre.id == 0 {
                    return CatSDKNetworkTattoo.rx.fetchTattoos(tattooType: tattoType, addressId: addressid)
                } else {
                    return CatSDKNetworkTattoo.rx.fetchTattosInSpecificCategory(categoryID: genre.id, tattooType: tattoType, addressId: addressid)
                }
            }

        dropDownItems = viewWillAppear
            .withLatestFrom(genreList)
            .asDriver(onErrorJustReturn: [])

        genreItems = fetchedItems
            .debug("==[==-===-=-=-=-")
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

        pushToTattooDetailVC = didTapTattooItem
            .withLatestFrom(fetchedItems) { row, items in items[row] }
            .map { model in TattooDetailViewModel(tattooModel: model) }
            .asDriver(onErrorJustReturn: .init(tattooModel: .empty))
    }
}
