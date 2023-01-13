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
// 문의하기랑 신고 및 피드백 ... ?
enum MyPageMenuType: Int, CaseIterable {
    case notice
    case feedback
    case termOfService
    case personalInfoAgreement
    case logout
    case withdrawal
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
        case .upgrade:
            return "안녕하세요 타투이스트 님!\n 타투를 등록하고싶으세요?"
        }
    }
    
    static func menus() -> [MyPageMenuType] {
        let menus = allCases
        // 제외할 것들
        switch CatSDKUser.userType() {
        case .guest:
            return menus.filter { !($0 == .logout || $0 == .withdrawal) }
        case .normal:
            return menus
        case .business:
            return menus
        }
    }
}
final class MyPageViewModel {
    
    // MARK: - Input
    let viewWillAppear = PublishRelay<Void>()
    let selectedItem = PublishRelay<IndexPath>()
    let profileEditButtonTapped = PublishRelay<Void>()
//    let loginButtonTapped = PublishRelay<Void>()
    
    // MARK: - Output
    let dataSourceDriver: Driver<[MyPageSection]>
    let logoutDriver: Driver<Void>
    let pushToProfileEditViewDriver: Driver<Void>
    let pushToWebViewDriver: Driver<String>
    let showLoginAlertVCDrvier: Driver<Void>
    let showUpgradeVCDriver: Driver<Void>
    
    init(useCase: MyPageUseCase = MyPageUseCase()) {
        let profileSectionDataObservable = viewWillAppear
            .map { CatSDKUser.user() }
            .map { MyPageProfileCellViewModel(user: $0) }
        
        let recentTattooSectionDataObservable = viewWillAppear
            .map { CatSDKTattoo.recentViewTattoos() }
        
        let menuSectionDataObservable = viewWillAppear
            .map { MyPageMenuType.menus() }
        
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
        logoutDriver = selectedMenu
            .debug("로그아웃")
            .filter { $0 == .logout }
            .do { _ in CatSDKUser.logout() }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        pushToWebViewDriver = selectedMenu.compactMap { $0.linkString() }
            .asDriver(onErrorJustReturn: "")
        
        let didTapUpgrade = selectedMenu
            .filter { $0 == .upgrade }
        
        showLoginAlertVCDrvier = didTapUpgrade
            .filter { _ in CatSDKUser.userType() == .guest }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())

        showUpgradeVCDriver = didTapUpgrade
            .filter { _ in CatSDKUser.userType() != .guest }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
    }
    
    func userType() -> Model.UserType {
        CatSDKUser.userType()
    }
}
