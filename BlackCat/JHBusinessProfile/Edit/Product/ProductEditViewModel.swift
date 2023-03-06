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
    
    func completeAlertMessage() -> String {
        switch self {
        case .add: return "타투가 등록되었습니다."
        case .modify: return "타투가 수정되었습니다."
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
    // MARK: - SubViewModels
    let tattooTypeViewModel: TattooTypeInputViewModel
    let titleInputViewModel: SimpleInputViewModel
    let priceInputViewModel: PriceInputViewModel
    let tattooImageInputViewModel: TattooImageInputViewModel
    let descriptionInputViewModel: TextInputViewModel
    let genreInputViewModel: GenreInputViewModel
    
    // MARK: - Input
    let imageListInputRelay = PublishRelay<[UIImage]>()
    let selectedIndexRelay = PublishRelay<IndexPath>()
    let didTapWariningRemoveViewConfirmButton = PublishRelay<Int?>()
    let didTapCompleteButton = PublishRelay<Void>()
    
    // MARK: - Output
    let pageTitleDriver: Driver<String>
    let imageListDrvier: Driver<[Any]>
    let showWarningRemoveViewDrvier: Driver<Int?>
    let showImagePickerViewDriver: Driver<Void>
    let OneButtonAlertDriver: Driver<String>
    let dismissDriver: Driver<String>
    
    init(tattoo: Model.Tattoo? = nil) {
        let tattooId = tattoo?.id
        let fetcedGenreList = Observable.just(GenreType.allCases)
        let initialImageUrlStrings = tattoo?.imageURLStrings ?? []
        let type: ProductInputType = tattoo == nil ? .add : .modify
        pageTitleDriver = .just(type.title())
        tattooTypeViewModel = .init(tattooType: tattoo?.tattooType)
        titleInputViewModel = .init(type: .tattooTitle, content: tattoo?.title)
        priceInputViewModel = .init(content: tattoo == nil ? "" : String(tattoo!.price))
        tattooImageInputViewModel = .init()
        descriptionInputViewModel = .init(title: "내용", content: tattoo?.description ?? "")
        genreInputViewModel = .init(genres: fetcedGenreList, selectedGenres: tattoo?.categoryIds ?? [])
        
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
            //TODO: - 가격 삽입
            priceInputViewModel.inputStringRelay,
            genreInputViewModel.selectedGenresRelay
        ).map { (type: $0, title: $1, images: $2, description: $3, price: $4, categoryIdList: $5) }
        
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
        
        let limitExcess = addedResultImages
            .delay(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .filter { $0.count > 5 }
            .map { _ in "최대 5개까지만 등록 가능합니다 !" }
        
        // NOTE: - 서버에 보낼 때
        // fetchedImage가 inputs에 포함되어 있지 않으면 deletedImages
        // UIImage타입이면 addedImages
        let inputsWhenDidTapCompleteButton = didTapCompleteButton
            .withLatestFrom(inputs)
            .map { validCheckedInputs(type: $0.type, title: $0.title, images: $0.images, description: $0.description, price: $0.price, categoryIdList: $0.categoryIdList) }
            .share()
        
        let updateResult = inputsWhenDidTapCompleteButton
            .filter { $0 != nil }
            .flatMap { request in
                guard let request else { return Observable.just(Model.TattooThumbnail(tattooId: -1, imageUrlString: "")) }
                let tattooInfo = request.0
                let imageDataList = request.1
                return CatSDKTattooist.updateProduct(tattooId: tattooId, tattooImageDatas: imageDataList, tattooInfo: tattooInfo)
            }.share()
        
        let validCheckFail = inputsWhenDidTapCompleteButton
            .filter { $0 == nil }
            .map { _ in "내용 이외의 값은 필수입니다." }
        
        let updateSuccess = updateResult
            .filter { $0.tattooId != -1 }
        
        let updateFail = updateResult
            .filter { $0.tattooId == -1 }
        
        let localUpdateSuccess = updateSuccess
            .do { tattooThumbnail in
                if type == .add {
                    var localTattooist = CatSDKTattooist.localTattooistInfo()
                    localTattooist.tattoos = [tattooThumbnail] + localTattooist.tattoos
                    CatSDKTattooist.updateLocalTattooistInfo(tattooistInfo: localTattooist)
                }
            }.map { _ in type.completeAlertMessage() }
        
        let updateFailMessage = updateFail
            .map { _ in "잠시 후 다시 시도해주세요." }
        
        OneButtonAlertDriver = Observable.merge([updateFailMessage, validCheckFail, limitExcess])
            .asDriver(onErrorJustReturn: "")
        
        dismissDriver = localUpdateSuccess
            .asDriver(onErrorJustReturn: "")
        
        imageListDrvier = images
            .asDriver(onErrorJustReturn: [])
        
        func shouldDeleteImages(inputImages: [Any]) -> [String] {
            initialImageUrlStrings.filter { initialImageUrlString in
                !inputImages.contains(where: { inputImage in
                    guard let imageUrlString = inputImage as? String else { return false }
                    return imageUrlString == initialImageUrlString
                })
            }
        }
        
        func shouldUpdateImages(inputImages: [Any]) -> [Data] {
            inputImages
                .compactMap { $0 as? UIImage }
                .compactMap { $0.resize(newWidth: 600).jpegData(compressionQuality: 0.1) }
        }
        
        func validCheckedInputs(
            type: TattooType?,
            title: String? = "",
            images: [Any],
            description: String,
            price: String,
            categoryIdList: Set<Int>
        ) -> (Model.UpdateTattoo.Request, [Data])? {
            guard let type else { return nil }
            guard let title, title != "" else { return nil }
            guard let priceInt = Int(price) else { return nil}
            if images.isEmpty || categoryIdList.isEmpty {
                return nil
            }
            
            return (.init(tattooType: type,
                          categoryId: categoryIdList.sorted(),
                          title: title, price: priceInt,
                          description: description,
                          deleteImageUrls: shouldDeleteImages(inputImages: images)),
                    shouldUpdateImages(inputImages: images))
        }
    }
}
