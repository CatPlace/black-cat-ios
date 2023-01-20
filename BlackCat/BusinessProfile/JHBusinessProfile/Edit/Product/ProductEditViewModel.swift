//
//  ProductEditViewModel.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/21.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa
import BlackCatSDK

enum ProductInputType {
    case add, modify
    
    func title() -> String {
        switch self {
        case .add: return "타투 업로드"
        case .modify: return "타투 수정"
        }
    }
}

class ProductEditViewModel {
    
    // MARK: - SubViewModels
    let titleInputViewModel: SimpleInputViewModel
    let tattooImageInputViewModel: TattooImageInputViewModel
    let descriptionInputViewModel: TextInputViewModel
    let genreInputViewModel: GenreInputViewModel
    
    // MARK: - Input
    let imageDataListInputRelay = PublishRelay<[Data]>()
    let selectedIndexRelay = PublishRelay<IndexPath>()
    let newImageDataListRelay = PublishRelay<[Data]>()
    let didTapWariningRemoveViewConfirmButton = PublishRelay<(IndexPath, [Data])>()
    let didTapCompleteButton = PublishRelay<Void>()
    
    // MARK: - Output
    let newImageDataListDrvier: Driver<[Data?]>
    let limitExcessDriver: Driver<Void>
    let showWarningRemoveViewDrvier: Driver<(IndexPath, [Data])>
    let showImagePickerViewDriver: Driver<Void>
    let showCompleteAlertViewDriver: Driver<Void>
    
    let type: ProductInputType
    
    init(tattoo: Model.Tattoo? = nil) {
        self.type = tattoo == nil ? .add : .modify
        
        let initialImageDataList: [Data] = tattoo?.imageURLStrings
            .compactMap {
                guard let url = URL(string: $0) else { return nil }
                return try? Data(contentsOf: url)
            } ?? []
        
        // TODO: - 타투모델에 제목이 없음... 왜?
        titleInputViewModel = .init(type: .tattooTitle, content: tattoo?.description)
        tattooImageInputViewModel = .init(imageDataList: initialImageDataList)
        descriptionInputViewModel = .init(title: "내용", content: tattoo?.description ?? "")
        genreInputViewModel = .init()
        
        
        let shouldUpdateData = selectedIndexRelay
            .withLatestFrom(tattooImageInputViewModel.imageDataListRelay) { indexPath, prevData in
                (indexPath, prevData.compactMap { $0 })
            }.share()
        
        let addedImageDataList = imageDataListInputRelay
            .withLatestFrom(tattooImageInputViewModel.imageDataListRelay) { inputData, prevData in
                var newDataList = prevData.compactMap { $0 }
                newDataList.append(contentsOf: inputData)
                return newDataList
            }
        
        let removedImageDataList = didTapWariningRemoveViewConfirmButton
            .map { (indexPath, preData) in
                var newData = preData
                newData.remove(at: indexPath.row)
                return newData
            }
        
        let newImageDataList = Observable.merge([
            .just(initialImageDataList),
            addedImageDataList,
            removedImageDataList
        ]).share()
        
        let inputs = Observable.combineLatest(titleInputViewModel.inputStringRelay,
                                               newImageDataList,
                                               descriptionInputViewModel.inputStringRelay
                                              ).share()
        
        
        showWarningRemoveViewDrvier = shouldUpdateData
            .filter { indexPath, prevData in
                prevData.count > indexPath.row
            }.asDriver(onErrorJustReturn: (IndexPath(), []))
        
        showImagePickerViewDriver = shouldUpdateData
            .filter { indexPath, prevData in
                prevData.count <= indexPath.row
            }.map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        newImageDataListDrvier = newImageDataList.filter { $0.count <= 5 }
            .map { imageDataList in
                var newDataList: [Data?] = imageDataList
                while newDataList.count < 5 {
                    newDataList.append(nil)
                }
                return newDataList
            }
            .asDriver(onErrorJustReturn: [])
        
        limitExcessDriver = newImageDataList.filter { $0.count > 5 }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        showCompleteAlertViewDriver = didTapCompleteButton
            .withLatestFrom(inputs)
            .debug("TODO: - 서버 통신")
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
    }
}
