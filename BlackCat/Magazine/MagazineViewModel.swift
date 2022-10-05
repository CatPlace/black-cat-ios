//
//  MagazineViewModel.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/05.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

// example Model
struct FamousMagazine {
    let imageUrl: String
    //... 등등
}

struct PreviewMagazine {
    let imageUrl: String
    let title: String
    let writer: String
    let date: String
    //... 등등
}

struct MagazineViewModel {

    //output
    var magazineFamousCellItems = PublishRelay<[FamousMagazine]>()
    var magazinePreviewCellItems = PublishRelay<[PreviewMagazine]>()
    
    var fetchedMagazineItems: Observable<[MagazineSection]>
    init() {
        fetchedMagazineItems = Observable.combineLatest(magazineFamousCellItems, magazinePreviewCellItems) { famouseCell, previewCell in
            [
                MagazineSection(items: [MagazineItem.MagazineFamousCell(famouseCell.map {
                    .init(imageUrl: $0.imageUrl)
                })]),
                MagazineSection(items: [MagazineItem.MagazinePreviewCell(previewCell.map{
                    .init(imageUrl: $0.imageUrl, title: $0.title, writer: $0.writer, date: $0.date)
                })])
            ]
        }
    }
}
