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
        // TODO: - 서버통신 후 권한 받아서 집어넣기 (유저디폴트에 의존하면 새로 로그인 시 이사람이 비즈니스 계정인지 명확하지 않음)
            .do {
                var user = $0
                user.userType = .normal
                CatSDKUser.updateUser(user: user)
            }
            .map { _ in () }
        
        showHomeViewControllerDriver = Observable.merge([lookAroundTrigger.asObservable(), loginSuccessResult])
            .asDriver(onErrorJustReturn: ())
        
        loginFailureDriver = loginResult
            .filter { $0.id == -2 }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
    }
    func isLogin() -> Bool {
        print("로그인 왜", CatSDKUser.userType() != .guest)
        return CatSDKUser.userType() != .guest
    }
}
