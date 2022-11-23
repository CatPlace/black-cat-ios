//
//  MyPageViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/23.
//

import UIKit

import RxDataSources
import BlackCatSDK
import RxSwift
import RxCocoa
import RxRelay

struct User {
    let jwt: String
    let name: String
}

struct Tattoo {
    let imageUrl: String // imgUrl or UIImage?
    let title: String
    let price: Int
}

class MyPageUseCase {
    func userProfile() -> Observable<User> {
        return .just(.init(jwt: "afgad", name: "김타투"))
    }
    
    func recentTattoo() -> Observable<[Tattoo]> {
        return .just([
            .init(imageUrl: "ㅁㄴㅇ", title: "타투 제목", price: 700000),
            .init(imageUrl: "ㅁ", title: "타투 제목", price: 1700000),
            .init(imageUrl: "ㄴ", title: "타투 제목", price: 2700000),
            .init(imageUrl: "ㄴ", title: "타투 제목", price: 2700000),
            .init(imageUrl: "ㄴ", title: "타투 제목", price: 2700000),
            .init(imageUrl: "ㄴ", title: "타투 제목", price: 2700000),
            .init(imageUrl: "ㄴ", title: "타투 제목", price: 2700000),
            .init(imageUrl: "ㄴ", title: "타투 제목", price: 2700000),
            .init(imageUrl: "ㄴ", title: "타투 제목", price: 2700000),
            .init(imageUrl: "ㄴ", title: "타투 제목", price: 2700000),
            .init(imageUrl: "ㄴ", title: "타투 제목", price: 2700000)
        ])
    }
}

class MyPageViewModel {
    
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

class MyPageViewController: UIViewController {
    enum Reusable {
        static let profileCell = ReusableCell<MyPageProfileCell>()
        static let tattooCell = ReusableCell<MyPageTattooCell>()
        static let menuCell = ReusableCell<MyPageMenuCell>()
    }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    lazy var dataSource = RxCollectionViewSectionedReloadDataSource<MyPageSection> (
        configureCell: { _, collectionView, indexPath, item in
            switch item {
            case .profileSection(let viewModel):
                let cell = collectionView.dequeue(Reusable.profileCell, for: indexPath)
                cell.backgroundColor = .red
                return cell
            case .recentTattooSection(let viewModel):
                let cell = collectionView.dequeue(Reusable.tattooCell, for: indexPath)
                cell.backgroundColor = .black
                return cell
            case .menuSection(let viewModel):
                let cell = collectionView.dequeue(Reusable.menuCell, for: indexPath)
                cell.bind(viewModel: viewModel)
                return cell
            }
        },
        configureSupplementaryView: { [weak self] _, collectionView, kind, indexPath -> UICollectionReusableView in
            guard MyPageSectionType(rawValue: indexPath.section) == .recentTattoo,
                  let self
            else { return UICollectionReusableView() }
            
            // TODO: Title
            return UICollectionReusableView()
        }
    )
    
    // MARK: - Binding
    func bind(to viewModel: MyPageViewModel) {
        rx.viewWillAppear
            .map { _ in () }
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)
        
        viewModel.dataSourceDriver
            .drive(myPageCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    // MARK: - Initializer
    init(viewModel: MyPageViewModel) {
        super.init(nibName: nil, bundle: nil)
        setUI()
        bind(to: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    lazy var myPageCollectionView: UICollectionView = {
        let layout = createLayout()
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.register(Reusable.profileCell)
        v.register(Reusable.tattooCell)
        v.register(Reusable.menuCell)
        return v
    }()
}

extension MyPageViewController {
    func setUI() {
        view.addSubview(myPageCollectionView)
        
        myPageCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
