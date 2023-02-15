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
    let viewModel: JHBusinessProfileViewModel
    
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
    
    // MARK: - Bindings
    func bind(viewModel: JHBusinessProfileViewModel) {
        disposeBag.insert {
            rx.viewWillAppear
                .bind(to: viewModel.viewWillAppear)
            
            editLabel.rx.tapGesture()
                .when(.recognized)
                .withUnretained(self)
                .bind { owner, _ in
                    print("편집 탭 !")
                }
            
            bottomView.askButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.pushToEditVC()
                }
            
            viewModel.sections
                .drive(self.collectionView.rx.items(dataSource: dataSource))
        }
        
        viewModel.visibleCellIndexPath
            .drive { row in
                guard let type = JHBPContentHeaderButtonType(rawValue: row) else { return }
                JHBPDispatchSystem.dispatch.multicastDelegate.invokeDelegates { delegate in
                    delegate.notifyContentHeader(indexPath: IndexPath(row: row, section: 0), forType: type)
                }
            }.disposed(by: disposeBag)
    }
    
    // MARK: function
    func updateEditButtonUI(selectedRow: Int) {
        
        guard let type = JHBPContentHeaderButtonType(rawValue: selectedRow), viewModel.isOwner else { return }
       
        bottomView.setAskButtonTag(selectedRow)
        bottomView.setAskingText(type.editButtonText())
        editLabel.isHidden = selectedRow != 1

    }
    
    func pushToEditVC() {
        // TODO: - 현재 가지고 있는 모델을 그대로 가져가기 ~ (수정)
        
        if let type = JHBPContentHeaderButtonType(rawValue: bottomView.askButtonTag()) {
            let nextVCWithNavi = UINavigationController(rootViewController: type.editVC())
            nextVCWithNavi.modalPresentationStyle = .fullScreen
            present(nextVCWithNavi, animated: true)
        } else { // TODO: - 문의하기
            print("문의하기 TODO")
        }

    }
    
    // MARK: Initialize
    init(viewModel: JHBusinessProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bind(viewModel: viewModel)
        if viewModel.isOwner {
            updateEditButtonUI(selectedRow: 0)
        }
        hidesBottomBarWhenPushed = true
        
        collectionView.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        JHBPDispatchSystem.dispatch.multicastDelegate.addDelegate(self)
        setNavigationBackgroundColor(color: .white.withAlphaComponent(0))
        appendNavigationLeftBackButton(color: .white)
        appendNavigationLeftLabel(title: "TEST", color: .white)
        appendNavigationRightLabel(editLabel)
    }

    // MARK: - UIComponents
    lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.contentInsetAdjustmentBehavior = .never
        cv.delegate = self
        cv.showsVerticalScrollIndicator = false
        cv.register(Reusable.thumbnailCell)
        cv.register(Reusable.contentCell)
        cv.register(Reusable.contentHeaderView, kind: .header)
        
        return cv
    }()
    let bottomView = AskBottomView()
    let editLabel: UILabel = {
        $0.text = "편집"
        $0.textColor = .white
        $0.font = .appleSDGoithcFont(size: 15, style: .regular)
        $0.isHidden = true
        return $0
    }(UILabel())
}

extension JHBusinessProfileViewController {
    func setUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(28)
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
                                                                         heightDimension: .fractionalHeight(0.8)),
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        section.visibleItemsInvalidationHandler = { [weak self] (items, offset, _) -> Void in
            guard let self else { return }
            let page = round(offset.x / self.view.bounds.width)

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

        notifyViewController(offset: 0, didChangeSection: true)
    }
    
    func notifyViewController(offset: CGFloat, didChangeSection: Bool) {

        if didChangeSection {
            self.collectionView.isScrollEnabled = true
            UIView.animate(withDuration: 0.3) {
                self.collectionView.contentOffset = CGPoint(x: 0, y: 250)
            }
        } else if offset > UIScreen.main.bounds.height / 1000 {
            self.collectionView.isScrollEnabled = false
            UIView.animate(withDuration: 0.3) {
                // 위쪽으로 y만큼 당긴다고 생각하기
                self.collectionView.contentOffset = CGPoint(x: 0, y: 250)
            }
        } else {
            collectionView.isScrollEnabled = true
            UIView.animate(withDuration: 0.3) {
                self.collectionView.contentOffset = CGPoint(x: 0, y: 0)
            }
        }
    }
}

extension JHBusinessProfileViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.bounces = scrollView.contentOffset.y > 250
        
        if scrollView.contentOffset.y > 250 {
            notifyViewController(offset: 1, didChangeSection: true)
        }
    }
}
