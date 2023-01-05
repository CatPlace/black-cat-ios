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
    
    func linkString() -> String? {
        switch self {
        case .notice:
            return "https://play.afreecatv.com/phonics1/244378743"
        case .feedback:
            return "https://tattoomap.notion.site/1-ef60c84317204542b27583ab82693671"
        case .termOfService:
            return "https://tattoomap.notion.site/d2c332b8900c414b96fc6ad97e774a27"
        case .personalInfoAgreement:
            return "https://tattoomap.notion.site/3af8802e66f74bba8d25a186a3c6d24d"
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
    
    // MARK: - Output
    let dataSourceDriver: Driver<[MyPageSection]>
    let logoutDriver: Driver<Void>
    let pushToProfileEditViewDriver: Driver<Void>
    let pushToWebViewDriver: Driver<String>
    
    init(useCase: MyPageUseCase = MyPageUseCase()) {
        let profileSectionDataObservable = viewWillAppear
            .flatMap { useCase.userProfile() }
            .map { MyPageProfileCellViewModel(user: $0) }
        
        let recentTattooSectionDataObservable = viewWillAppear
            .map{ CatSDKTattoo.recentViewTattoos() }
        
        let menuSectionDataObservable: Observable<[MyPageMenuType]> = Observable.just(MyPageMenuType.menus())
        
        let selectedMenu = selectedItem
            .filter { MyPageSectionType(rawValue: $0.section) == .menu }
            .compactMap {  MyPageMenuType(rawValue: $0.row) }
        
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
            .filter { $0 == .logout }
            .do { _ in CatSDKUser.logout() }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        pushToWebViewDriver = selectedMenu.compactMap { $0.linkString() }
            .asDriver(onErrorJustReturn: "")
    }
}
