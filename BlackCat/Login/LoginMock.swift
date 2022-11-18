//
//  LoginMock.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/18.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

// third party로 분리할 부분
class BlackCatSocialLoginSDK {
    enum SocialLoginType {
        case kakao, apple
        
        func buttonImageName() -> String {
            switch self {
            case .kakao:
                return "ic_home"
            case .apple:
                return "ic_chat"
            }
        }
    }
    
//    func accessToken(type: SocialLoginType) {
//        switch type {
//        case .kakao:
//
//        case .apple:
//
//        }
//    }
}

// BlackCat에서 사용할 부분 (BlackCatSocialLoginSDK, 우리가 만든 UserRepository에 의존)
public class BlackCatLoginSDK {
    
}
