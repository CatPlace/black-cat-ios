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


final class MyPageViewController: UIViewController {
    enum Reusable {
        static let profileCell = ReusableCell<MyPageProfileCell>()
        static let tattooCell = ReusableCell<CommonTattooInfoCell>()
        static let menuCell = ReusableCell<MyPageMenuCell>()
        static let tattooHeaderView = ReusableView<RecentTattooHeaderView>()
    }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var viewModel: MyPageViewModel
    
    lazy var dataSource = RxCollectionViewSectionedReloadDataSource<MyPageSection> (
        configureCell: { _, collectionView, indexPath, item in
            switch item {
            case .profileSection(let viewModel):
                let cell = collectionView.dequeue(Reusable.profileCell, for: indexPath)
                
                cell.bind(to: viewModel, with: self.viewModel)

                return cell
            case .recentTattooSection(let viewModel):
                let cell = collectionView.dequeue(Reusable.tattooCell, for: indexPath)
                
                cell.bind(to: viewModel)
                
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
            
            let v = collectionView.dequeue(Reusable.tattooHeaderView, kind: .header, for: indexPath)
            v.bind(to: .init(text: "최근 본 타투", backgroundColor: .clear))
            return v
        }
    )
    
    // MARK: - Binding
    func bind(to viewModel: MyPageViewModel) {
        rx.viewWillAppear
            .map { _ in () }
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)
        
        myPageCollectionView.rx.itemSelected
            .bind(to: viewModel.selectedItem)
            .disposed(by: disposeBag)
        
        viewModel.dataSourceDriver
            .drive(myPageCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.logoutDriver
            .drive(with: self) { owner, _ in
                //TODO: Alert 추가
                owner.dismiss(animated: false)
            }.disposed(by: disposeBag)
        
        viewModel.pushToProfileEditViewDriver
            .drive(with: self) { owner, _ in
                let vc = ProfileViewController(
                    viewModel: .init(
                        nameInputViewModel: .init(title: "이름"),
                        emailInputViewModel: .init(title: "이메일"),
                        phoneNumberInputViewModel: .init(title: "전화번호"),
                        genderInputViewModel: .init(),
                        areaInputViewModel: .init()
                    )
                )
                vc.hidesBottomBarWhenPushed = true
                owner.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: disposeBag)
        
        viewModel.pushToWebViewDriver
            .drive(with: self) { owner, linkString in
                let vc = WebViewController(linkString: linkString)
                owner.navigationController?.pushViewController(vc, animated: true)
                print(linkString)
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Initializer
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
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
        v.register(Reusable.tattooHeaderView, kind: .header)
        return v
    }()
    
    deinit {
        print("deinit")
    }
}

extension MyPageViewController {
    func setUI() {
        view.addSubview(myPageCollectionView)
        
        myPageCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
