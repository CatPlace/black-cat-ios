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
    let imageListInputRelay = PublishRelay<[UIImage]>()
    let selectedIndexRelay = PublishRelay<IndexPath>()
    let didTapWariningRemoveViewConfirmButton = PublishRelay<Int>()
    let didTapCompleteButton = PublishRelay<Void>()
    
    // MARK: - Output
    let imageListDrvier: Driver<[Any]>
    let limitExcessDriver: Driver<Void>
    let showWarningRemoveViewDrvier: Driver<Int>
    let showImagePickerViewDriver: Driver<Void>
    let showCompleteAlertViewDriver: Driver<Void>
    
    init(tattoo: Model.Tattoo? = nil) {
        self.type = tattoo == nil ? .add : .modify
        let fetcedGenreList = CatSDKNetworkCategory.rx.fetchCategories()
            .debug("장르 ~")
            .share()
        
        // TODO: - 타투모델에 제목이 없음... 왜?
        titleInputViewModel = .init(type: .tattooTitle, content: tattoo?.description)
        tattooImageInputViewModel = .init()
        descriptionInputViewModel = .init(title: "내용", content: tattoo?.description ?? "")
        
        // TODO: - 타투모델에 장르가 없음... 왜 ?
        genreInputViewModel = .init(genres: fetcedGenreList)
        
        // TODO:  서버 요청
        let fetchedImages = Observable.just(["https://www.chemicalnews.co.kr/news/photo/202106/3636_10174_4958.jpg", "https://www.chemicalnews.co.kr/news/photo/202106/3636_10174_4958.jpg"])
            .map { $0.map { $0 as Any } }
            .share()
        
        let addedResultImages = imageListInputRelay
            .withLatestFrom(tattooImageInputViewModel.imageDataListRelay) { inputImages, prevImages in
                var newImages = prevImages
                newImages.append(contentsOf: inputImages)
                return newImages
            }.share()
        
        let removedResultImages = didTapWariningRemoveViewConfirmButton
            .withLatestFrom(tattooImageInputViewModel.imageDataListRelay) { index, prevImages in
                print(index, prevImages)
                var newImages = prevImages
                newImages.remove(at: index)
                return newImages
            }

        let shouldUpdatedImages = addedResultImages
            .filter { $0.count <= 5 }
            
        let images: Observable<[Any]> = Observable.merge([fetchedImages, shouldUpdatedImages, removedResultImages])
            .debug("이미지들")
            .share(replay: 1)
        
        let shouldUpdateData = selectedIndexRelay
            .withLatestFrom(images) {
                ($0, $1)
            }.share()
        
        let inputs = Observable.combineLatest(titleInputViewModel.inputStringRelay,
                                              images,
                                               descriptionInputViewModel.inputStringRelay
        )

        showWarningRemoveViewDrvier = shouldUpdateData
            .filter { indexPath, images in
                indexPath.row < images.count
            }.map { $0.0.row }
            .asDriver(onErrorJustReturn: -1)
        
        showImagePickerViewDriver = shouldUpdateData
            .filter { indexPath, images in
                indexPath.row >= images.count
            }.map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        limitExcessDriver = addedResultImages
            .filter { $0.count > 5 }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        showCompleteAlertViewDriver = didTapCompleteButton
            .withLatestFrom(inputs)
            .withLatestFrom(fetchedImages){ inputs, fetchedImages in
                (inputs, fetchedImages)
            }
            // NOTE: - 서버에 보낼 때
            // fetchedImage가 inputs에 포함되어 있지 않으면 deletedImages
            // UIImage타입이면 addedImages
            .debug("TODO: - 서버 통신")
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        imageListDrvier = images
            .asDriver(onErrorJustReturn: [])
    }
}
