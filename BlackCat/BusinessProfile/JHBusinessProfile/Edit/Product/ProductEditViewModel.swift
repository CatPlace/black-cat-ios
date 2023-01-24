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
    
    // MARK: - Property
    let type: ProductInputType
    
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
    
    init(tattoo: Model.Tattoo? = nil) {
        self.type = tattoo == nil ? .add : .modify
        var initialImageUrlStrings: [String] = tattoo?.imageURLStrings ?? []
        var serverImageUrlStrings: [String?] = tattoo?.imageURLStrings ?? []
        
        serverImageUrlStrings = ["https://www.chemicalnews.co.kr/news/photo/202106/3636_10174_4958.jpg", "https://www.chemicalnews.co.kr/news/photo/202106/3636_10174_4958.jpg"]
        
        let initialImageDataList: [Data] = serverImageUrlStrings
            .compactMap { urlString in
                guard let urlString, let url = URL(string: urlString) else { return nil }
                return try? Data(contentsOf: url)
            }
        
        let fetcedGenreList = CatSDKNetworkCategory.rx.fetchCategories()
            .debug("장르 ~")
            .share()
        
        // TODO: - 타투모델에 제목이 없음... 왜?
        titleInputViewModel = .init(type: .tattooTitle, content: tattoo?.description)
        tattooImageInputViewModel = .init(imageDataList: initialImageDataList)
        descriptionInputViewModel = .init(title: "내용", content: tattoo?.description ?? "")
        
        // TODO: - 타투모델에 장르가 없음... 왜 ?
        genreInputViewModel = .init(genres: fetcedGenreList)
        
        
        let shouldUpdateData = selectedIndexRelay
            .withLatestFrom(tattooImageInputViewModel.imageDataListRelay) { indexPath, prevData in
                (indexPath, prevData.compactMap { $0 })
            }.share()
        
        let addedImageDataList = imageDataListInputRelay
            .withLatestFrom(tattooImageInputViewModel.imageDataListRelay) { inputData, prevData in
                var newDataList = prevData.compactMap { $0 }
                newDataList.append(contentsOf: inputData)
                serverImageUrlStrings.append(contentsOf: Array(repeating: nil, count: inputData.count))
                return newDataList
            }
        
        let removedImageDataList = didTapWariningRemoveViewConfirmButton
            .map { (indexPath, preData) in
                var newData = preData
                newData.remove(at: indexPath.row)
                serverImageUrlStrings.remove(at: indexPath.row)
                return newData
            }
        
        let newImageDataList = Observable.merge([
            .just(initialImageDataList),
            addedImageDataList,
            removedImageDataList
        ]).share(replay: 1)
    
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
        // TODO: -
        //  deletedImageUrl = initialImageUrlStrings 순회 -> serverImageUrlStrings에 없는거
        // addedImageData = serverImageUrlStrings이 nil이면 그 인덱스에 해당하는 이미지 Data들
            .withLatestFrom(inputs)
            .do { _ in print(serverImageUrlStrings) }
            .debug("TODO: - 서버 통신")
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
    }
}
