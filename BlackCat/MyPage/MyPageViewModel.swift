//
//  MyPageViewModel.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/24.
//

import Foundation

import RxSwift
import RxCocoa
import RxRelay

final class MyPageViewModel {
    
    // MARK: - Input
    let viewWillAppear = PublishRelay<Void>()
    
    // MARK: - Output
    let dataSourceDriver: Driver<[MyPageSection]>
    
    init(useCase: MyPageUseCase = MyPageUseCase()) {
        let profileSectionDataObservable = viewWillAppear
            .flatMap { useCase.userProfile() }
        
        let recentTattooSectionDataObservable = viewWillAppear
            .flatMap { useCase.recentTattoo() }
        
        let menuSectionDataObservable = Observable.just(["공지사항", "문의하기", "서비스 이용약관", "개인정보 수집 및 이용", "신고 및 피드백", "로그아웃", "회원 탈퇴"])
        
        dataSourceDriver = Observable.combineLatest(
            profileSectionDataObservable,
            recentTattooSectionDataObservable,
            menuSectionDataObservable
        ) { firstSectionData, secondSectionData, thirdSectionData in
            [
                MyPageSection(items: [.profileSection(.init(user: firstSectionData))] ),
                MyPageSection(items: secondSectionData.map { .recentTattooSection(.init(tattoo: $0)) }),
                MyPageSection(items: thirdSectionData.map { .menuSection(.init(title: $0)) })
            ]
        }.asDriver(onErrorJustReturn: [])
        
    }
}
