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
        
        let menuSectionDataObservable: Observable<[MyPageMenuType]> = Observable.just([
            .notice,
            .inquiry,
            .termOfService,
            .PersonalInfoAgreement,
            .feedback,
            .logout,
            .withdrawal
        ])
        
        dataSourceDriver = Observable.combineLatest(
            profileSectionDataObservable,
            recentTattooSectionDataObservable,
            menuSectionDataObservable
        ) { firstSectionData, secondSectionData, thirdSectionData in
            [
                MyPageSection(items: [.profileSection(.init(user: firstSectionData))] ),
                MyPageSection(items: secondSectionData.map { .recentTattooSection(.init(tattoo: $0)) }),
                MyPageSection(items: thirdSectionData.map { .menuSection(.init(type: $0)) })
            ]
        }.asDriver(onErrorJustReturn: [])
        
    }
}
