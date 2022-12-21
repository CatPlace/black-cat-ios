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
    var didTapSocialLoginButton = PublishRelay<Int>()
    
    // MARK: - Output
    var loginSuccessDriver: Driver<Void>
    var loginFailureDriver: Driver<Void>
    
    init() {
        let types = socialLoginTypes
        
        let loginResult = didTapSocialLoginButton
            .debug("💡User")
            .map { types[$0] }
            .flatMap(CatSDKUser.login)
            .catch { error in
                    .just(.init(id: -1))
            }.debug("asd")
        
        loginSuccessDriver = loginResult
            .filter { $0.jwt != nil }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        loginFailureDriver = loginResult
            .filter { $0.jwt == nil }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
    }
}
