//
//  JHBusinessProfileViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/12/28.
//

import UIKit

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
    
    lazy var dataSource: ManageMentDataSource = ManageMentDataSource { _, collectionView, indexPath, items in
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
    } configureSupplementaryView: { [weak self] _, collectionView, kind, indexPath -> UICollectionReusableView in
        guard let self else { return UICollectionReusableView() }
        switch indexPath.section {
        case 0: return UICollectionReusableView()
        case 1:
            var contentHeaderView = collectionView.dequeue(Reusable.contentHeaderView, kind: .header, for: indexPath)
            contentHeaderView.bind(viewModel: self.viewModel.headerViewModel)
            return contentHeaderView
        default: return UICollectionReusableView()
        }
    }

    // MARK: - Bindings
    func bind(viewModel: JHBusinessProfileViewModel) {
        disposeBag.insert {
            rx.viewWillAppear
                .map { _ in () }
                .bind(to: viewModel.viewWillAppear)

            rx.viewDidAppear
                .map { _ in () }
                .bind(to: viewModel.viewDidAppear)

            editLabel.rx.tapGesture()
                .when(.recognized)
                .withUnretained(self)
                .bind { owner, _ in
                    if owner.editLabel.text == "완료" {
                        owner.bottomView.setAskingText("타투 업로드")
                        owner.bottomView.setAskButtonTag(1)
                    }

                    JHBPDispatchSystem.dispatch.multicastDelegate.invokeDelegates { delegate in
                        delegate.notifyCellCollectionView()
                    }
                }

            bottomView.askButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.pushToEditVC()
                }

            viewModel.sections
                .drive(self.collectionView.rx.items(dataSource: dataSource))
        }

        viewModel.visibleCellIndexPath
            .drive(with: self) { owner, row in
                guard let type = JHBPContentHeaderButtonType(rawValue: row) else { return }
                JHBPDispatchSystem.dispatch.multicastDelegate.invokeDelegates { delegate in
                    delegate.notifyContentHeader(indexPath: IndexPath(row: row, section: 0), forType: type)
                }
            }.disposed(by: disposeBag)

        viewModel.showTattooDetail
            .drive(with: self) { owner, tattooId in
                // TODO: - 화면 전환
                print(tattooId, "디테일 ㄱ ㄱ !")
//                                owner.navigationController?.pushViewController(TattooDetailViewController(viewModel: .init(tattooModel: .ini)), animated: <#T##Bool#>)
            }.disposed(by: disposeBag)

        viewModel.scrollToTypeDriver
            .drive(with: self) { owner, type in
                viewModel.headerViewModel.selectedButton.accept(type)
            }.disposed(by: disposeBag)

        viewModel.initEditModeDriver
            .drive(with: self) { owner, _ in
                let cell = owner.collectionView.cellForItem(at: IndexPath(row: 1, section: 1)) as? JHBPContentCell
                cell?.viewModel?.editMode.accept(.normal)
            }.disposed(by: disposeBag)

        viewModel.deleteSuccessDriver
            .drive(with: self) { owner, _ in
                viewModel.deleteCompleteRelay.accept(())
                let vc = OneButtonAlertViewController(viewModel: .init(content: "삭제되었습니다.", buttonText: "확인"))
                owner.present(vc, animated: true)
            }.disposed(by: disposeBag)

        viewModel.deleteFailDriver
            .drive(with: self) { owner, _ in
                let vc = OneButtonAlertViewController(viewModel: .init(content: "삭제에 실패했습니다.", buttonText: "확인"))
                owner.present(vc, animated: true)
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
        /// tag = [0: 소개, 1: 작품, 2: 견적, 3: 타투 삭제]
        if bottomView.askButtonTag() == 3 {
            let vc = TwoButtonAlertViewController(viewModel: .init(type: .warningDelete(viewModel.currentDeleteProductIndexList)))
            vc.delegate = self
            present(vc, animated: true)
        } else if let type = JHBPContentHeaderButtonType(rawValue: bottomView.askButtonTag()) {
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
        print("비즈니스 프로필 이닛")
        bind(viewModel: viewModel)
        if !viewModel.isOwner {
            bottomView.isHidden = true
            editLabel.isHidden = true
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
        setUI()
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
        return UICollectionViewCompositionalLayout { [weak self] section, env -> NSCollectionLayoutSection? in

            // 🐻‍❄️ NOTE: - section을 Int값이 아니라 BPSection타입으로 변경하기
            switch section {
            case 0: return self?.thumbnailLayoutSection()
            case 1: return self?.contentLayoutSection()
            default: return self?.contentLayoutSection()
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
            let adjustedOffsetX = offset.x / self.view.bounds.width
            if adjustedOffsetX == floor(adjustedOffsetX) {
                self.viewModel.cellDidAppear.accept(adjustedOffsetX)
            }

            let page = round(adjustedOffsetX)

            self.viewModel.cellWillAppear.accept(page)
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
    func notifyViewController(editMode: EditMode) {
        editLabel.text = editMode.asStringInTattooEdit()
        bottomView.bookmarkView.isHidden = editMode == .edit
        if editMode == .edit {
            bottomView.setAskingText("삭제")
            bottomView.setAskButtonTag(3)
            bottomView.layoutIfNeeded()
            bottomView.askButton.snp.remakeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.width.equalTo(Constant.width * 100)
                $0.centerX.equalToSuperview()
            }
        } else {

            bottomView.askButton.snp.remakeConstraints {
                $0.top.leading.bottom.equalToSuperview()
                $0.width.equalTo(Constant.width * 251)
            }
        }

        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            self.bottomView.layoutIfNeeded()
        }
    }

    func notifyViewController(selectedIndex: IndexPath, forType: type) {
        viewModel.selectedTattooIndex.accept(selectedIndex.row)
    }

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
            collectionView.isScrollEnabled = true
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.collectionView.contentOffset = CGPoint(x: 0, y: 250)
            }
        } else if offset > UIScreen.main.bounds.height / 1000 {
            collectionView.isScrollEnabled = false
            UIView.animate(withDuration: 0.3) { [weak self] in
                // 위쪽으로 y만큼 당긴다고 생각하기
                self?.collectionView.contentOffset = CGPoint(x: 0, y: 250)
            }
        } else {
            collectionView.isScrollEnabled = true
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.collectionView.contentOffset = CGPoint(x: 0, y: 0)
            }
        }
    }

    func notifyViewController(currentDeleteProductIndexList: [Int]) {
        viewModel.currentDeleteProductIndexList = currentDeleteProductIndexList
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

extension JHBusinessProfileViewController: TwoButtonAlertViewDelegate {
    func didTapRightButton(type: TwoButtonAlertType) {
        switch type {
        case .warningDelete(let indexList):
            viewModel.deleteProductTrigger.accept(indexList)
            break
        default: break
        }
        dismiss(animated: true)
    }

    func didTapLeftButton(type: TwoButtonAlertType) {
        dismiss(animated: true)
    }
}

