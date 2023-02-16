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

struct TattooEditModel {
    let id: Int?
    let tattooType: String
    let categoryId: Int
    let title: String
    let price: Int
    let description: String
    let deleteImageUrls: [String]
    let images: [Data]
}

class ProductEditViewModel {
    // MARK: - Property
    let type: ProductInputType
    
    // MARK: - SubViewModels
    let tattooTypeViewModel: TattooTypeInputViewModel
    let titleInputViewModel: SimpleInputViewModel
    let tattooImageInputViewModel: TattooImageInputViewModel
    let descriptionInputViewModel: TextInputViewModel
    let genreInputViewModel: GenreInputViewModel
    
    // MARK: - Input
    let imageListInputRelay = PublishRelay<[UIImage]>()
    let selectedIndexRelay = PublishRelay<IndexPath>()
    let didTapWariningRemoveViewConfirmButton = PublishRelay<Int?>()
    let didTapCompleteButton = PublishRelay<Void>()
    
    // MARK: - Output
    let imageListDrvier: Driver<[Any]>
    let limitExcessDriver: Driver<Void>
    let showWarningRemoveViewDrvier: Driver<Int?>
    let showImagePickerViewDriver: Driver<Void>
    let showCompleteAlertViewDriver: Driver<Void>
    let showFailUpdateAlertViewDriver: Driver<String>
    init(tattoo: Model.Tattoo? = nil) {
        let tattooId = tattoo?.id
        let fetcedGenreList = CatSDKNetworkCategory.rx.fetchCategories()
            .debug("장르 ~")
            .share()
        
        let initialUpdateTattooModel: Model.UpdateTattoo.Request
        let initialImageUrlStrings = tattoo?.imageURLStrings ?? []
        
        if let tattoo {
            type = .modify
            initialUpdateTattooModel = .init(tattooType: tattoo.tattooType, categoryId: tattoo.categoryId, title: tattoo.title, price: tattoo.price, description: tattoo.description, deleteImageUrls: [])
        } else {
            type = .add
            initialUpdateTattooModel = .init()
        }
        
        tattooTypeViewModel = .init(tattooType: initialUpdateTattooModel.tattooType)
        titleInputViewModel = .init(type: .tattooTitle, content: initialUpdateTattooModel.description)
        tattooImageInputViewModel = .init()
        descriptionInputViewModel = .init(title: "내용", content: initialUpdateTattooModel.description)
        genreInputViewModel = .init(genres: fetcedGenreList, selectedGenres: initialUpdateTattooModel.categoryId)
        
        let addedResultImages = imageListInputRelay
            .withLatestFrom(tattooImageInputViewModel.imageDataListRelay) { inputImages, prevImages in
                var newImages = prevImages
                newImages.append(contentsOf: inputImages)
                return newImages
            }.share()
        
        
        let removedResultImages = didTapWariningRemoveViewConfirmButton
            .withLatestFrom(tattooImageInputViewModel.imageDataListRelay) { index, prevImages in
                var newImages = prevImages
                guard let index else { return newImages }
                newImages.remove(at: index)
                return newImages
            }
        
        let shouldUpdatedImages = addedResultImages
            .filter { $0.count <= 5 }
        
        let images: Observable<[Any]> = Observable.merge([.just(initialImageUrlStrings), shouldUpdatedImages, removedResultImages])
            .share(replay: 1)
        
        let shouldUpdateData = selectedIndexRelay
            .withLatestFrom(images) {
                ($0, $1)
            }.share()
        
        let inputs = Observable.combineLatest(
            tattooTypeViewModel.tattooTypeRelay,
            titleInputViewModel.inputStringRelay,
            images,
            descriptionInputViewModel.inputStringRelay,
            genreInputViewModel.selectedGenresRelay
        ).map { (type: $0, title: $1, images: $2, description: $3, categoryIdList: $4) }
        
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
        
        // NOTE: - 서버에 보낼 때
        // fetchedImage가 inputs에 포함되어 있지 않으면 deletedImages
        // UIImage타입이면 addedImages
        let updateResult = didTapCompleteButton
            .withLatestFrom(inputs)
            .map { input -> (Model.UpdateTattoo.Request, [Data]) in
                return (.init(tattooType: input.type, categoryId: input.categoryIdList.sorted(), title: input.title, price: 0, description: input.description, deleteImageUrls: shouldDeleteImages(inputImages: input.images)), shouldUpdateImages(inputImages: input.images))
            }.flatMap { tattooInfo, imageDataList in
                CatSDKTattooist.updateProduct(tattooistId: tattooId, tattooImageDatas: imageDataList, tattooInfo: tattooInfo)
            }
        
        let updateSuccess = updateResult.filter { $0.tattooId != -1 }
        let updateFail = updateResult.filter { $0.tattooId == -1 }
        
        
        showFailUpdateAlertViewDriver = updateFail
            .map { _ in "잠시 후 다시 시도해주세요." }
            .asDriver(onErrorJustReturn: "")
        
        showCompleteAlertViewDriver = updateSuccess
            .do { tattooThumbnail in
                var localTattooist = CatSDKTattooist.localTattooistInfo()
                localTattooist.tattoos = [tattooThumbnail] + localTattooist.tattoos
                CatSDKTattooist.updateLocalTattooistInfo(tattooistInfo: localTattooist)
            }.map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        imageListDrvier = images
            .asDriver(onErrorJustReturn: [])
        
        func shouldDeleteImages(inputImages: [Any]) -> [String] {
            initialImageUrlStrings.filter { initialImageUrlString in
                inputImages.contains(where: { inputImage in
                    guard let imageUrlString = inputImage as? String else { return false }
                    return imageUrlString == initialImageUrlString
                })
            }
        }
        
        func shouldUpdateImages(inputImages: [Any]) -> [Data] {
            inputImages
                .compactMap { $0 as? UIImage }
                .compactMap { $0.resize(newWidth: 20).jpegData(compressionQuality: 0.1) }
        }
    }
}
