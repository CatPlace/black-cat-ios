//
//  ProfileEditViewModel.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import BlackCatSDK

class ProfileEditViewModel {
    
    var introduceEditViewModel: TextInputViewModel = .init(title: "자기소개")
    
    var didTapCompleteButton = PublishRelay<Void>()
    
    var updateSuccessDriver: Driver<Void>
    var updateFailDriver: Driver<String>
    
    var imageRelay: BehaviorRelay<Any?> // Data or urlString
    var imageDriver: Driver<UIImage?>
    var introduceDriver: Driver<String>
    
    init() {
        var localTattooistInfo = CatSDKTattooist.localTattooistInfo()
        let initialImageUrlString = localTattooistInfo.introduce.imageUrlString
        imageRelay = .init(value: initialImageUrlString)
        introduceDriver = .just(localTattooistInfo.introduce.introduce)
        imageDriver = imageRelay
            .flatMap(UIImage.convertToUIImage)
            .asDriver(onErrorJustReturn: UIImage(systemName: "trash"))
        
        let updatedResult = didTapCompleteButton
            .withLatestFrom(imageRelay)
            .withLatestFrom(introduceEditViewModel.baseTextViewModel.inputStringRelay) { ($0, $1) }
            .flatMap { finalImage, introduce in
                let images: [Data]?
                let deleteImageUrls: [String]
                if let _ = finalImage as? String {
                    images = nil
                    deleteImageUrls = []
                } else if let image = finalImage as? UIImage, let data = image.resize(newWidth: 20).jpegData(compressionQuality: 0.1) {
                    images = [data]
                    deleteImageUrls = [initialImageUrlString].compactMap { $0 }
                } else {
                    images = nil
                    deleteImageUrls = [initialImageUrlString].compactMap { $0 }
                }
                return CatSDKTattooist.updateProfile(introduce: introduce, deleteImageUrls: deleteImageUrls, images: images ?? [])
            }.share()
        
        updateSuccessDriver = updatedResult
            .filter { $0.introduce != "error" }
            .map { updatedTattooistIntroduce in
                localTattooistInfo.introduce = updatedTattooistIntroduce
                CatSDKTattooist.updateLocalTattooistInfo(tattooistInfo: localTattooistInfo)
                return ()
            }.asDriver(onErrorJustReturn: ())
        
        updateFailDriver = updatedResult
            .filter { $0.introduce == "error" }
            .map { $0.introduce }
            .asDriver(onErrorJustReturn: "")
    }
}
