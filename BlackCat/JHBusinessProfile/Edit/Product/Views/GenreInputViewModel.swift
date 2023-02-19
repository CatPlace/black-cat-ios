//
//  GenreInputViewModel.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/25.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay
import BlackCatSDK

class GenreInputViewModel {
    
    let selectedGenresRelay: BehaviorRelay<Set<Int>>
    let selectedIndexRelay = PublishRelay<IndexPath>()
    
    let updateIndexSetDriver: Driver<Set<Int>>
    let cellViewModelsDriver: Driver<[GenreInputCellViewModel]>
    init(genres: Observable<[Model.Category]>, selectedGenres: [Int] = []) {
        selectedGenresRelay = .init(value: Set(selectedGenres.map { $0 }))
            
        let newSelectedGenres = selectedIndexRelay
            .withLatestFrom(selectedGenresRelay) { indexPath, preSelectedIndex in
                (indexPath.row + 1, preSelectedIndex)
            }.map { index, indexSet in
                var newSet = indexSet
                if !newSet.insert(index).inserted {
                    newSet.remove(index)
                }
                return newSet
            }.filter { $0.count <= 3 }

        updateIndexSetDriver = newSelectedGenres
            .asDriver(onErrorJustReturn: Set())
        
        cellViewModelsDriver = Observable.combineLatest(selectedGenresRelay, genres)
            .map { indexSet, genres in
                genres.filter { $0.id != 0 }
                    .map { GenreInputCellViewModel(genre: $0, isSelected: indexSet.contains($0.id)) }
            }.asDriver(onErrorJustReturn: [])
    }
}
