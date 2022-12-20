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
    var resultDriver: Driver<Void>
    
    init() {
        let types = socialLoginTypes
        
        resultDriver = didTapSocialLoginButton
            .debug("💡User")
            .map { types[$0] }
            .flatMap(CatSDKUser.login)
            .catch { error in
                    .just(.init(id: -1))
            }
            
//            .map { result in
//                switch result {
//                case .success(let a):
//                    print(a)
//                case .failure(let b):
//                    print(b)
//                }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
    }
}
