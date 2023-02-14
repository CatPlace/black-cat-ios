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
            .share()
        
        let loginSuccessResult = loginResult
            .filter { $0.id != -2 }
            .debug("로그인한 유저정보 🌈🌈🌈🌈")
            .do { CatSDKUser.updateUser(user: $0) }
            .map { _ in () }
        
        let lookAroundTriggerResult = lookAroundTrigger
            .do { _ in CatSDKUser.updateUser(user: .init(id: -2))} // TODO: userType 삭제
        
        showHomeViewControllerDriver = Observable.merge([lookAroundTriggerResult, loginSuccessResult])
            .do { _ in CatSDKTattooist.updateLocalTattooistInfo(tattooistInfo: .init()) }
            .asDriver(onErrorJustReturn: ())
        
        loginFailureDriver = loginResult
            .filter { $0.id == -2 }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
    }
    
    func isLogin() -> Bool {
        return CatSDKUser.userType() != .guest
    }
}
