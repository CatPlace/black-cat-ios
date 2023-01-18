//
//  JHBusinessProfileViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/12/28.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import RxDataSources
import BlackCatSDK

final class JHBusinessProfileViewController: UIViewController {
    typealias ManageMentDataSource = RxCollectionViewSectionedAnimatedDataSource<JHBusinessProfileCellSection>
    
    enum Reusable {
        static let thumbnailCell = ReusableCell<JHBPThumbnailImageCell>()
        static let contentCell = ReusableCell<JHBPContentCell>()
        static let contentHeaderView = ReusableView<JHBPContentSectionHeaderView>()
    }
    
    var disposeBag: DisposeBag = DisposeBag()
    let viewModel: JHBUsinessProfileViewModel
    let dataSource: ManageMentDataSource = ManageMentDataSource { _, collectionView, indexPath, items in
        switch items {
        case .thumbnailImageItem(let viewModel):
            let cell = collectionView.dequeue(Reusable.thumbnailCell, for: indexPath)
            
            cell.bind(viewModel: viewModel)
            
            return cell
        case .contentItem(let viewModel):
            let cell = collectionView.dequeue(Reusable.contentCell, for: indexPath)
            
            cell.bind(viewModel: viewModel)
            
            return cell
        }
    } configureSupplementaryView: { _, collectionView, kind, indexPath -> UICollectionReusableView in
        
        switch indexPath.section {
        case 0: return UICollectionReusableView()
        case 1:
            var contentHeaderView = collectionView.dequeue(Reusable.contentHeaderView, kind: .header, for: indexPath)
            contentHeaderView.bind(viewModel: .init())
            return contentHeaderView
        default: return UICollectionReusableView()
        }
    }
    
    func bind(viewModel: JHBUsinessProfileViewModel) {
        disposeBag.insert {
            bottomView.askButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.pushToEditVC()
                }
            
            viewModel.sections
                .bind(to: self.collectionView.rx.items(dataSource: dataSource))
        }
        
        
        viewModel.visibleCellIndexPath
            .drive { row in
                guard let type = JHBPContentSectionHeaderView.JHBPContentHeaderButtonType(rawValue: row) else { return }
                print(type, row)
                JHBPDispatchSystem.dispatch.multicastDelegate.invokeDelegates { delegate in
                    delegate.notifyContentHeader(indexPath: IndexPath(row: row, section: 0), forType: type)
                }
            }.disposed(by: disposeBag)
    }
    
    // MARK: function
    func updateEditButtonUI(selectedRow: Int) {
        typealias JHBPContentHeaderButtonType = JHBPContentSectionHeaderView.JHBPContentHeaderButtonType
        
        bottomView.setAskButtonTag(selectedRow)
        let type = JHBPContentHeaderButtonType(rawValue: selectedRow)
        var text = "test"
        switch type {
        case .profile:
            text = "수정하기"
        case .product:
            text = "타투 업로드"
        case .info:
            text = "견정 수정"
        case .none: break
        }
        bottomView.setAskingText(text)
    }
    
    func pushToEditVC() {
        typealias JHBPContentHeaderButtonType = JHBPContentSectionHeaderView.JHBPContentHeaderButtonType
        let type = JHBPContentHeaderButtonType(rawValue: bottomView.askButtonTag())
        // TODO: - 현재 가지고 있는 모델을 그대로 가져가기 ~ (수정)
        let nextVC: UIViewController
        switch type {
        case .profile:
            nextVC = ProfileEditViewController()
        case .product:
            nextVC = ProductEditViewController()
        case .info:
            nextVC = PriceInfoEditViewController()
        case .none:
            nextVC = UIViewController()
        }
        let nextVCWithNavi = UINavigationController(rootViewController: nextVC)
        nextVCWithNavi.modalPresentationStyle = .overFullScreen
        present(nextVCWithNavi, animated: true)
    }
    
    // MARK: Initialize
    init(viewModel: JHBUsinessProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bind(viewModel: viewModel)
        updateEditButtonUI(selectedRow: 0)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        JHBPDispatchSystem.dispatch.multicastDelegate.addDelegate(self)
    }
    
    // MARK: - UIComponents
    lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.contentInsetAdjustmentBehavior = .never
        cv.isScrollEnabled = false
        
        cv.register(Reusable.thumbnailCell)
        cv.register(Reusable.contentCell)
        cv.register(Reusable.contentHeaderView, kind: .header)
        
        return cv
    }()
    let bottomView = AskBottomView()
}


extension JHBusinessProfileViewController {
    func setUI() {
        self.navigationController?.navigationBar.isHidden = true
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(28)
            $0.height.equalTo(60)
        }
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection in
            
            // 🐻‍❄️ NOTE: - section을 Int값이 아니라 BPSection타입으로 변경하기
            switch section {
            case 0: return self.thumbnailLayoutSection()
            case 1: return self.contentLayoutSection()
            default: return self.contentLayoutSection()
            }
        }
    }
    
    private func thumbnailLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .fractionalWidth(1.0)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                         heightDimension: .fractionalWidth(1)),
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    private func contentLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .fractionalHeight(1.0)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                         heightDimension: .fractionalHeight(0.7)),
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        section.visibleItemsInvalidationHandler = { [weak self] (items, offset, _) -> Void in
            guard let self else { return }
            let page = round(offset.x / self.view.bounds.width)
            print(page)
            self.viewModel.cellDisplayingIndexRowRelay.accept(page)
        }
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                              heightDimension: .absolute(UIScreen.main.bounds.width * 40 / 375)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        header.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [header]
        
        return section
    }
}

extension JHBusinessProfileViewController: JHBPMulticastDelegate {
    func notifyContentHeader(indexPath: IndexPath, forType: type) {
        updateEditButtonUI(selectedRow: indexPath.row)
    }
    func notifyContentCell(indexPath: IndexPath?, forType: type) {
        collectionView.scrollToItem(at: IndexPath(row: forType.rawValue, section: 1),
                                    at: .top,
                                    animated: false)
    }
    
    func notifyViewController(offset: CGFloat) {
        
        // 🐻‍❄️ NOTE: - 'offset <= ?' ?를 정해 볼까요?
        //        if offset <= UIScreen.main.bounds.height / 3 {
        if offset <= 1 {
            UIView.animate(withDuration: 0.3) {
                self.collectionView.contentOffset = CGPoint(x: 0, y: 0)
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                // 위쪽으로 y만큼 당긴다고 생각하기
                self.collectionView.contentOffset = CGPoint(x: 0, y: 200)
            }
        }
    }
}
