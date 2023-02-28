//
//  MyPageViewModel.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/24.
//

import UIKit

import RxSwift
import RxCocoa
import RxRelay
import BlackCatSDK
// 문의하기랑 신고 및 피드백 ... ?
enum MyPageMenuType: Int, CaseIterable {
    case notice
    case feedback
    case termOfService
    case personalInfoAgreement
    case logout
    case withdrawal
    case login
    case upgrade
    
    func linkString() -> String? {
        switch self {
        case .notice:
            return "https://tattoomap.notion.site/fa94adab104043eca1127287909b9925"
        case .feedback:
            return "https://tattoomap.notion.site/87e0fa8faea0466bb3b83643283e70e1"
        case .termOfService:
            return "https://tattoomap.notion.site/62b2ccf1a1f1408e8874c8fb214bdcc6"
        case .personalInfoAgreement:
            return "https://tattoomap.notion.site/2ad2e7fec3a647638ef6b06800d05d89"
        default:
            return nil
        }
    }
    
    func menuTitle() -> String {
        switch self {
        case .notice:
            return "공지사항"
        case .feedback:
            return "문의하기"
        case .termOfService:
            return "서비스 이용약관"
        case .personalInfoAgreement:
            return "개인정보 처리방침"
        case .logout:
            return "로그아웃"
        case .withdrawal:
            return "회원 탈퇴"
        case .login:
            return "로그인 및 회원가입"
        case .upgrade:
            return "타투이스트 계정 업그레이드!"
        }
    }
    
    static func menus() -> [MyPageMenuType] {
        let menus = allCases
        switch CatSDKUser.userType() {
        case .guest:
            return [.notice, .termOfService, .login]
        case .normal:
            return menus.filter { $0 != .login }
        case .business:
            return menus.filter { $0 != .login && $0 != .upgrade }
        }
    }
}
final class MyPageViewModel {
    typealias TattooistId = Int
    typealias ProfileId = Int
    
    // MARK: - Input
    let viewWillAppear = PublishRelay<Void>()
    let selectedItem = PublishRelay<IndexPath>()
    let profileEditButtonTapped = PublishRelay<Void>()
    let manageButtonTapped = PublishRelay<Void>()
    let logoutTrigger = PublishRelay<Void>()
    let withdrawalTriggier = PublishRelay<Void>()
    
    // MARK: - Output
    let dataSourceDriver: Driver<[MyPageSection]>
    let pushToProfileEditViewDriver: Driver<Void>
    let pushToWebViewDriver: Driver<String>
    let showLoginAlertVCDrvier: Driver<Void>
    let showUpgradeVCDriver: Driver<Void>
    let showBusinessProfileDriver: Driver<TattooistId>
    let showTwoButtonAlertVCDrvier: Driver<TwoButtonAlertType>
    let popToLoginVCDriver: Driver<Void>
    let showTattooDetailDriver: Driver<Int>
    let recentTattooIsEmptyDriver: Driver<Bool>
    
    init(useCase: MyPageUseCase = MyPageUseCase()) {
        let profileSectionDataObservable = viewWillAppear
            .map { CatSDKUser.user() }
            .map { MyPageProfileCellViewModel(user: $0) }
            .share()
        
        let recentTattooSectionDataObservable = viewWillAppear
            .flatMap { CatSDKTattoo.recentViewTattoos() }
            .share()
        
        let menuSectionDataObservable = viewWillAppear
            .map { MyPageMenuType.menus() }
            .share()
        
        let selectedMenu = selectedItem
            .filter { MyPageSectionType(rawValue: $0.section) == .menu }
            .withLatestFrom(menuSectionDataObservable) { ($0, $1) }
            .compactMap {  $0.1[$0.0.row] }
        
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
        let didTapLogout = selectedMenu
            .filter { $0 == .logout }
            .map { _ in () }
        
        let didTapLogin = selectedMenu
            .filter { $0 == .login }
            .map { _ in () }
        
        let didTapUpgrade = selectedMenu
            .filter { $0 == .upgrade }
            .map { _ in () }
        
        let didTapWithdrawal = selectedMenu
            .filter { $0 == .withdrawal }
            .map { _ in () }
        
        pushToWebViewDriver = selectedMenu
            .compactMap { $0.linkString() }
            .asDriver(onErrorJustReturn: "")
        
        let logoutResult = logoutTrigger
            .map { _ in CatSDKUser.logout() }
        
        let withdrawalResult = withdrawalTriggier
            .flatMap { CatSDKUser.withdrawal() }
        
        let withdrawlAlertType = didTapWithdrawal.map { _ in TwoButtonAlertType.warningSecession }
        
        let logoutAlertType = didTapLogout.map { _ in TwoButtonAlertType.warningLogoutWriting }
        
        let withdrawalSuccess = withdrawalResult
            .filter { $0 }
            .map { _ in () }
        
        let withdrawalFail = withdrawalResult
            .filter { !$0 }
            .map { _ in () }
        
        let selectedTattoo = selectedItem
            .filter { $0.section == 1 }
            .withLatestFrom(recentTattooSectionDataObservable) { ($0, $1) }
            .map { $1[$0.row].id }
            .share()
        
        showTattooDetailDriver = selectedTattoo
            .asDriver(onErrorJustReturn: -1)
        
        popToLoginVCDriver = Observable.merge([logoutResult, withdrawalSuccess])
            .asDriver(onErrorJustReturn: ())
        
        showTwoButtonAlertVCDrvier = Observable.merge([logoutAlertType, withdrawlAlertType])
            .asDriver(onErrorJustReturn: .warningLogoutWriting)
        
        showLoginAlertVCDrvier = didTapLogin
            .filter { _ in CatSDKUser.userType() == .guest }
            .asDriver(onErrorJustReturn: ())

        showUpgradeVCDriver = didTapUpgrade
            .filter { _ in CatSDKUser.userType() != .guest }
            .asDriver(onErrorJustReturn: ())
        
        showBusinessProfileDriver = manageButtonTapped
            .map { _ in CatSDKUser.user().id }
            .asDriver(onErrorJustReturn: -1)
        
        recentTattooIsEmptyDriver = recentTattooSectionDataObservable
            .map { $0.isEmpty }
            .asDriver(onErrorJustReturn: true)
    }
    
    deinit {
        print("메모리 해제 잘되나 TEST, 마이페이지")
    }
}
