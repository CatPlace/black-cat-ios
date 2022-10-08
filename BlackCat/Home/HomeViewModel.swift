//
//  HomeViewModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/05.
//

import Foundation

import RxCocoa
import RxDataSources
import RxSwift

class HomeViewModel {

    // MARK: - Properties

    private let categoryItemTitles = Observable<[HomeCategory]>.just(HomeCategory.default)

    // View -> ViewModel

    let viewDidLoad = PublishRelay<Void>()
    let didTapSearchBarButtonItem = PublishRelay<Void>()
    let didTapHeartBarButtonItem = PublishRelay<Void>()

    // ViewModel -> View

    let homeItems: Driver<[HomeSection]>

    init() {
        let startFetchItems = viewDidLoad.share()

        let fetchedSection1Items = startFetchItems
            .map { () -> [Section1] in
                [
                    Section1(imageURLString: "", priceString: "", tattooistName: "")
                ]
            }

        let fetchedSection2Items = startFetchItems
            .map { () -> [Section2] in
                [
                    Section2(imageURLString: "")
                ]
            }

        homeItems = Observable
            .combineLatest(
                categoryItemTitles, fetchedSection1Items, fetchedSection2Items
            ) { categoryItems, section1Items, section2Items -> [HomeSection] in
                [
                    HomeSection(items: categoryItems.map { .HomeCategoryCellItem($0) }),
                    HomeSection(header: "항목 1", items: section1Items.map { .Section1($0) }),
                    HomeSection(items: [.Empty(Empty())]),
                    HomeSection(header: "항목 2", items: section2Items.map { .Section2($0) })
                ]
            }.asDriver(onErrorJustReturn: [])

        didTapHeartBarButtonItem
            .subscribe(onNext: {
                print("DidTapHeartBarButtonItem")
            })
            .dispose()

        didTapSearchBarButtonItem
            .subscribe(onNext: {
                print("DidTapSearchBarButtonItem")
            })
            .dispose()
    }

}

struct HomeSection {
    var header: String = ""
    var items: [Item]

    enum HomeItem {
        case HomeCategoryCellItem(HomeCategory)
        case Section1(Section1)
        case Empty(Empty)
        case Section2(Section2)
    }
}

extension HomeSection: SectionModelType {
    typealias Item = HomeItem

    init(original: HomeSection, items: [Item] = []) {
        self = original
        self.items = items
    }
}
