//
//  ProfileViewModel.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/05.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay
import BlackCatSDK

class ProfileViewModel {
    enum Purpose: Int {
        case edit, upgrade
    }
    
    // MARK: - SubViewModels
    let nameInputViewModel: ProfileTextInputViewModel
    let emailInputViewModel: ProfileTextInputViewModel
    let phoneNumberInputViewModel: ProfileTextInputViewModel
    let genderInputViewModel: GenderInputViewModel
    let areaInputViewModel: AreaInputViewModel
    
    
    // MARK: - Input
    let completeButtonTapped = PublishRelay<Void>()
    
    // MARK: - Output
    let completeAlertDriver: Driver<Void>
    let alertMassageDriver: Driver<String>
    
    init(nameInputViewModel: ProfileTextInputViewModel,
         emailInputViewModel: ProfileTextInputViewModel,
         phoneNumberInputViewModel: ProfileTextInputViewModel,
         genderInputViewModel: GenderInputViewModel,
         areaInputViewModel: AreaInputViewModel,
         type: Purpose = .edit) {
        
        CatSDKUser.initUserCache()
        
        self.nameInputViewModel = nameInputViewModel
        self.emailInputViewModel = emailInputViewModel
        self.phoneNumberInputViewModel = phoneNumberInputViewModel
        self.genderInputViewModel = genderInputViewModel
        self.areaInputViewModel = areaInputViewModel
        
        // TODO: 데이터 -> 캐시데이터 -> 완료버튼 누르면 서버 후 알러트
//        let combinedInputs = Observable.combineLatest(
//            nameInputViewModel.inputStringRelay,
//            emailInputViewModel.inputStringRelay,
//            phoneNumberInputViewModel.inputStringRelay,
//            genderInputViewModel.genderCellInfosRelay,
//            areaInputViewModel.areaCellInfosRelay
//        ) {
//            ($0, $1, $2, $3, $4, )
//        }
        
        let inputs = completeButtonTapped
            .map { _ in (CatSDKUser.userCache(), type)}
            .share()
        
        let alertMessage = inputs
            .filter { !($1 == .edit || checkValidInputs(inputs: $0)) }
            .map { _ in "모든 항목 필수값입니다."}
        
        let shouldUpdateProfile = inputs
            .filter { $1 == .edit || checkValidInputs(inputs: $0) }
        
        // TODO: - 서버통신
        let updatedResult = shouldUpdateProfile.map { _ in () }
        
        // TODO: - 서버통신 분기처리 ? 에러 및 성공
        completeAlertDriver = updatedResult
            .asDriver(onErrorJustReturn: ())
        
        alertMassageDriver = alertMessage
            .asDriver(onErrorJustReturn: "일시적인 오류입니다. 문의 해주시면 감사드리곘습니다.")
        
        func checkValidInputs(inputs user: Model.User) -> Bool {
            guard let name = user.name, let email = user.email, let phoneNumber = user.phoneNumber, let _ = user.gender else {
                return false
            }
            return !name.isEmpty &&
            !email.isEmpty &&
            !phoneNumber.isEmpty &&
            !user.areas.isEmpty
        }
    }
}
