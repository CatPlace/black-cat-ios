//
//  LoginMock.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/18.
//

import Foundation
import BlackCatSDK

import RxSwift
import RxCocoa
import RxRelay
public class BlackCatUserSDK {
    enum loginType {
        case kakao, apple
        
        func buttonImageName() -> String {
            switch self {
            case .kakao:
                return "login_kakao"
            case .apple:
                return "login_apple"
            }
        }
    }
    static func login(type: loginType) -> Observable<Result<Model.User, Error>>{
        print(type)
        return .just(.success(Model.User(jwt: "a", name: "b", imageUrl: "c")))
    }
    
    static func logout() {
        
    }
    
    static func 탈퇴() {
        
    }
}

