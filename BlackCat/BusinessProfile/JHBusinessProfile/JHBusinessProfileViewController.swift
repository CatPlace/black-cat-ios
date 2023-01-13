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
            editButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.pushToEditVC()
                }
            
            viewModel.sections
                .bind(to: self.collectionView.rx.items(dataSource: dataSource))
        }
    }
    
    // MARK: function
    func updateEditButtonUI(selectedRow: Int) {
        typealias JHBPContentHeaderButtonType = JHBPContentSectionHeaderView.JHBPContentHeaderButtonType
        
        editButton.tag = selectedRow
        let type = JHBPContentHeaderButtonType(rawValue: selectedRow)
        
        switch type {
        case .profile:
            editButton.setTitle("프로필 수정", for: .normal)
        case .product:
            editButton.setTitle("타투 추가", for: .normal)
        case .info:
            editButton.setTitle("견적 수정", for: .normal)
        case .none: break
        }
        
    }
    
    func pushToEditVC() {
        typealias JHBPContentHeaderButtonType = JHBPContentSectionHeaderView.JHBPContentHeaderButtonType
        let type = JHBPContentHeaderButtonType(rawValue: editButton.tag)
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
    let editButton: UIButton = {
        $0.setTitleColor(.red, for: .normal)
        $0.backgroundColor = .black
        return $0
    }(UIButton())
}


extension JHBusinessProfileViewController {
    func setUI() {
        self.navigationController?.navigationBar.isHidden = true
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(editButton)
        editButton.snp.makeConstraints {
            $0.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
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
                                    animated: true)
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
