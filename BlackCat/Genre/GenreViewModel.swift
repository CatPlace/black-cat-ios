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
    
//    static func id(_ title: String) -> Int {
//        allGenre.firstIndex { $0.title == title } ?? 0
//    }

    var imageName: String {
        switch self {
        case .전체보기: return "all"
        case .레터링: return "lettering"
        case .미니타투: return "mini"
        case .감성타투: return "sentimental"
        case .이레즈미: return "irezumi"
        case .블랙그레이: return "blackAndGray"
        case .라인워크: return "lineWork"
        case .헤나: return "henna"
        case .커버업: return "coverUp"
        case .뉴스쿨: return "newSchool"
        case .올드스쿨: return "oldSchool"
        case .잉크스플래쉬: return "inkSplash"
        case .치카노: return "chicano"
        case .컬러: return "color"
        case .캐릭터: return "charactor"
        }
    }
}

struct FilterInfo: Equatable {
    let genreId: Int
    let tattooTypes: [String]
    let addressIds: [Int]
}

class GenreViewModel {

    let disposeBag = DisposeBag()
    var genre: GenreType

    // MARK: - Input

    private let genreList = Observable<[String]>.just(GenreType.allCases.map { $0.title })
    let viewWillAppear = PublishRelay<Void>()
    let filterViewDidDismiss = PublishRelay<Void>()
    let selectedDropDownItemRow = PublishRelay<Int>()
    let didTapTattooItem = PublishRelay<Int>()

    // MARK: - Output

    let dropDownItems: Driver<[String]>
    // Home에서도 사용하는 Cell이라 Common으로 이동할 필요가 있어 보입니다.
    let genreItems: Driver<[CommonFullImageCellViewModel]>
    let pushToTattooDetailVC: Driver<TattooDetailViewModel>

    init(genre: GenreType) {
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
                            .map { $0 + 1 }
                }
            }

        let filteredInfo = Observable.zip(filteredTask, filteredLocation)
            .share()

        let defaultGenreId = Observable.just(genre.rawValue)

        let changedGenreId = selectedDropDownItemRow.asObservable()

        let currentGenreId = Observable.merge([
            defaultGenreId,
            changedGenreId
        ]).distinctUntilChanged()
            .share()

        let fetchedItems = Observable.merge([
            filteredTrigger,
            selectedDropDownItemRow.map { _ in () }.asObservable()
        ])
            .withLatestFrom(filteredInfo)
            .withLatestFrom(currentGenreId) { FilterInfo(genreId: $1, tattooTypes: $0.0, addressIds: $0.1) }
            .distinctUntilChanged()
            .debug("필터 정보들➡️➡️➡️")
            .flatMap { filterInfo in
                let tattooTypes = filterInfo.tattooTypes.isEmpty ? nil : filterInfo.tattooTypes
                let addressIds = filterInfo.addressIds.isEmpty ? nil : filterInfo.addressIds
                let genreId = filterInfo.genreId == 0 ? nil : filterInfo.genreId
                return CatSDKTattoo.fetchedTattoo(categoryId: genreId, page: 0, size: 1000, tattooTypes: tattooTypes, addressIds: addressIds)
            }.share()

        dropDownItems = genreList
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
