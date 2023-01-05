//
//  LoginViewModel.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/12/04.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay
import BlackCatSDK

class LoginViewModel {
    let socialLoginTypes: [CatSDKUser.LoginType] = [.kakao, .apple]
    
    // MARK: - Input
    let didTapSocialLoginButton = PublishRelay<Int>()
    let lookAroundTrigger = PublishRelay<Void>()
    
    // MARK: - Output
    var showHomeViewControllerDriver: Driver<Void>
    var loginFailureDriver: Driver<Void>
    
    init() {
        let types = socialLoginTypes
        
        let loginResult = didTapSocialLoginButton
            .map { types[$0] }
            .flatMap(CatSDKUser.login)
            .catch { error in
                print(error)
                return .just(.init(id: -2))
            }
        
        let loginSuccessResult = loginResult
            .filter { $0.id != -2 }
            .do { CatSDKUser.updateLocalUser(user: $0)}
            .map { _ in () }
        
        showHomeViewControllerDriver = Observable.merge([lookAroundTrigger.asObservable(), loginSuccessResult])
            .asDriver(onErrorJustReturn: ())
        
        loginFailureDriver = loginResult
            .filter { $0.id == -2 }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
    }
}
