//
//  ProfileViewModel.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/05.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import BlackCatSDK

class ProfileViewModel {
    enum Purpose: Int {
        case edit, upgrade
    }
    
    // MARK: - SubViewModels
    let nameInputViewModel: SimpleInputViewModel
    let emailInputViewModel: SimpleInputViewModel
    let phoneNumberInputViewModel: SimpleInputViewModel
    let genderInputViewModel: GenderInputViewModel
    let areaInputViewModel: AreaInputViewModel
    
    // MARK: - Input
    let imageInputRelay: BehaviorRelay<Any?>
    let completeButtonTapped = PublishRelay<Void>()
    let upgradeTrigger = PublishRelay<Void>()
    
    // MARK: - Output
    let completeAlertDriver: Driver<Void>
    let alertMassageDriver: Driver<String>
    let profileImageDriver: Driver<UIImage?>
    
    init(type: Purpose = .edit) {
        let user = CatSDKUser.user()
        
        let isTattooist = user.userType == .business
        
        var initialImageUrl = user.imageUrl
        
        imageInputRelay = .init(value: initialImageUrl)
        self.nameInputViewModel = .init(type: .profileName, content: user.name)
        self.emailInputViewModel = .init(type: .profileEmail, content: user.email)
        self.phoneNumberInputViewModel = .init(type: .profliePhoneNumber, content: user.phoneNumber)
        self.genderInputViewModel = .init(gender: user.gender)
        self.areaInputViewModel = .init(area: user.area)
        
        let combinedInputs = Observable.combineLatest(
            nameInputViewModel.inputStringRelay,
            emailInputViewModel.inputStringRelay,
            phoneNumberInputViewModel.inputStringRelay,
            genderInputViewModel.genderInputRelay,
            areaInputViewModel.areaInputRelay,
            Observable.just(type)
        ) {
            (Model.User(id: -1, jwt: nil, name: $0, imageUrl: nil, email: $1, phoneNumber: $2, gender: $3, area: $4, userType: .guest), $5)
        }

        
        let inputs = completeButtonTapped
            .withLatestFrom(combinedInputs)
            .share()
        
        
        
        let alertMessage = inputs
            .filter { !isRequiredInputs(inputs: $0, mode: $1) }
            .map { _ in "모든 항목 필수값입니다."}
        
        let shouldUpdateProfile = inputs
            .filter { isRequiredInputs(inputs: $0, mode: $1) }
        
        let updatedResult = shouldUpdateProfile
            .withLatestFrom(imageInputRelay) { ($0.0, $1) }
            .flatMap { user, finalImage in
                let images: [Data]?
                let deleteImageUrls: [String]
                if let _ = finalImage as? String {
                    images = nil
                    deleteImageUrls = []
                } else if let image = finalImage as? UIImage, let data = image.resize(newWidth: 10).jpegData(compressionQuality: 0.01) {
                    images = [data]
                    deleteImageUrls = [initialImageUrl].compactMap { $0 }
                } else {
                    images = nil
                    deleteImageUrls = [initialImageUrl].compactMap { $0 }
                }
                return CatSDKUser.updateUserProfile(user: user, deleteImageUrls: deleteImageUrls, images: images)
            }.share()
        
        let updateSuccess = updatedResult.filter { $0 }
        let updateFail = updatedResult.filter { !$0 }
        
        let editSuccess = updateSuccess
            .filter { _ in type == .edit }
            .map { _ in () }
        
        // TODO: - 서버통신 (role을 tattooist로 변경)
        let upgradeReulst = updateSuccess
            .filter { _ in type == .upgrade }
            .flatMap { _ in CatSDKUser.updateRole() }
            .share()
        
        let upgradeSuccess = upgradeReulst
            .filter { $0 }
            .map { _ in
                var user = CatSDKUser.user()
                user.userType = .business
                CatSDKUser.updateUser(user: user)
                return ()
            }
        
        let upgradeFail = upgradeReulst
            .filter { !$0 }
            .map { _ in () }
        
        completeAlertDriver = Observable.merge([editSuccess, upgradeSuccess])
            .asDriver(onErrorJustReturn: ())
        
        alertMassageDriver = Observable.merge([alertMessage, updateFail.map { _ in "업데이트 실패" }, upgradeFail.map { _ in "업그레이드 실패"}])
            .asDriver(onErrorJustReturn: "일시적인 오류입니다. 문의 해주시면 감사드리곘습니다.")
        
        profileImageDriver = imageInputRelay
            .flatMap(UIImage.convertToUIImage)
            .asDriver(onErrorJustReturn: nil)
        
        func checkValidInputs(inputs user: Model.User) -> Bool {
            guard let name = user.name, let email = user.email, let phoneNumber = user.phoneNumber, user.gender != nil, user.area != nil else {
                return false
            }
            return !name.isEmpty &&
            !email.isEmpty &&
            !phoneNumber.isEmpty
        }
        
        func isRequiredInputs(inputs: Model.User, mode: Purpose) -> Bool {
            let isRequired = (mode == .upgrade || isTattooist)
            return isRequired ? checkValidInputs(inputs: inputs) : true
        }
    }
}
