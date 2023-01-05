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
import BlackCatSDK

final class MyPageViewModel {
    
    // MARK: - Input
    let viewWillAppear = PublishRelay<Void>()
    let selectedItem = PublishRelay<IndexPath>()
    let profileEditButtonTapped = PublishRelay<Void>()
    
    // MARK: - Output
    let dataSourceDriver: Driver<[MyPageSection]>
    let logoutDriver: Driver<Void>
    let pushToProfileEditViewDriver: Driver<Void>
    
    init(useCase: MyPageUseCase = MyPageUseCase()) {
        let profileSectionDataObservable = viewWillAppear
            .flatMap { useCase.userProfile() }
            .map { MyPageProfileCellViewModel(user: $0) }
        
        let recentTattooSectionDataObservable = viewWillAppear
            .map{ CatSDKTattoo.recentViewTattoos() }
            
        let menuSectionDataObservable: Observable<[MyPageMenuType]> = Observable.just([
            .notice,
            .inquiry,
            .termOfService,
            .PersonalInfoAgreement,
            .feedback,
            .logout,
            .withdrawal
        ])
        
        pushToProfileEditViewDriver = profileEditButtonTapped
            .asDriver(onErrorJustReturn: ())
        
        dataSourceDriver = Observable.combineLatest(
            profileSectionDataObservable,
            recentTattooSectionDataObservable,
            menuSectionDataObservable
        ) { firstSectionData, secondSectionData, thirdSectionData in
            return [
                MyPageSection(items: [.profileSection(firstSectionData)] ),
                MyPageSection(items: secondSectionData.map { .recentTattooSection(.init(tattoo: $0)) }),
                MyPageSection(items: thirdSectionData.map { .menuSection(.init(type: $0)) })
            ]
        }.asDriver(onErrorJustReturn: [])
     
        //TODO: - 알러트 추가 후 수정
        logoutDriver = selectedItem.filter { MyPageSectionType(rawValue: $0.section) == .menu }
            .filter { MyPageMenuType(rawValue: $0.row)?.menuTitle() == "로그아웃" }
            .map { _ in () }
            .do { _ in CatSDKUser.logout() }
            .asDriver(onErrorJustReturn: ())
    }
}
