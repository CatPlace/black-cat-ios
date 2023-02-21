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

        let filteredTrigger = Observable.merge([
            viewWillAppear.asObservable(),
            filterViewDidDismiss.asObservable()
        ]).share()

        let filterService = FilterService()

        let filteredTask = filteredTrigger
            .flatMap {
                filterService.taskService.fetch()
                    .map {
                    $0.filter { $0.isSubscribe == true }
                            .map { $0.type.serverString() }
                }
            }
            

        let filteredLocation = filteredTrigger
            .flatMap {
                filterService.locationService.fetch()
                    .map {
                    $0.filter { $0.isSubscribe == true }
                            .compactMap { $0.type.index() }
                }
            }

        let filteredInfo = Observable.zip(filteredTask, filteredLocation)
            .share()

        let defaultGenreId = viewWillAppear
            .map { _ in genre.id }

        let changedGenreId = selectedDropDownItemRow.asObservable()

        let currentGenreId = Observable.merge([
            defaultGenreId,
            changedGenreId
        ]).share()

        let fetchedItems = Observable.merge([
            viewWillAppear.asObservable(),
            filterViewDidDismiss.asObservable(),
            selectedDropDownItemRow.map { _ in () }.asObservable()
        ])
            .withLatestFrom(filteredInfo)
            .withLatestFrom(currentGenreId) { (filterInfo: $0, genreId: $1) }
            .flatMap { filterInfo, genreId in
                let tattooTypes = filterInfo.0.isEmpty ? nil : filterInfo.0
                let addressIds = filterInfo.1.isEmpty ? nil : filterInfo.1
                return CatSDKTattoo.fetchedTattoo(categoryId: genreId == 0 ? nil : genreId, page: 0, size: 20, tattooTypes: tattooTypes, addressIds: addressIds)
            }.share()

        dropDownItems = viewWillAppear
            .withLatestFrom(genreList)
            .asDriver(onErrorJustReturn: [])

        genreItems = fetchedItems
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
            .map { model in TattooDetailViewModel(tattooId: model.id) }
            .asDriver(onErrorJustReturn: .init(tattooId: -1))
    }
}
