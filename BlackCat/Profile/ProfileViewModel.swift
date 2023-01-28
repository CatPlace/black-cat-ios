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
    
    // MARK: - Output
    let completeAlertDriver: Driver<Purpose>
    let alertMassageDriver: Driver<String>
    let profileImageDriver: Driver<UIImage?>
    
    init(type: Purpose = .edit) {
        let user = CatSDKUser.user()
        imageInputRelay = .init(value: user.imageUrl)
        self.nameInputViewModel = .init(type: .profileName, content: user.name)
        self.emailInputViewModel = .init(type: .profileEmail, content: user.email)
        self.phoneNumberInputViewModel = .init(type: .profliePhoneNumber, content: user.phoneNumber)
        self.genderInputViewModel = .init(gender: user.gender)
        self.areaInputViewModel = .init(area: user.area)
        
        // TODO: 데이터 -> 캐시데이터 -> 완료버튼 누르면 서버 후 알러트
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
            .debug("프로필 데이터들")
            .share()
        
        let alertMessage = inputs
            .filter { !($1 == .edit || checkValidInputs(inputs: $0)) }
            .map { _ in "모든 항목 필수값입니다."}
        
        let shouldUpdateProfile = inputs
            .filter { $1 == .edit || checkValidInputs(inputs: $0) }
        
        // TODO: - 서버통신
        let updatedResult = shouldUpdateProfile
            .map { _ in () }
        
        // TODO: - 서버통신 분기처리 ? 에러 및 성공
        completeAlertDriver = updatedResult
            .map { _ in type }
            .asDriver(onErrorJustReturn: .edit)
        
        alertMassageDriver = alertMessage
            .asDriver(onErrorJustReturn: "일시적인 오류입니다. 문의 해주시면 감사드리곘습니다.")
        
        profileImageDriver = imageInputRelay
            .flatMap(UIImage.convertToUIImage)
            .asDriver(onErrorJustReturn: nil)
        
        func checkValidInputs(inputs user: Model.User) -> Bool {
            print(user)
            guard let name = user.name, let email = user.email, let phoneNumber = user.phoneNumber, user.gender != nil, user.area != nil else {
                return false
            }
            
            return !name.isEmpty &&
            !email.isEmpty &&
            !phoneNumber.isEmpty
        }
    }
}
