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

            rx.viewWillDisappear
                .map { _ in () }
                .bind(to: viewModel.viewWillDisappear)
            
            bottomView.bookmarkView.rx.tapGesture()
                .when(.recognized)
                .withUnretained(self)
                .map { owner, _ in
                    owner.bottomView.heartButton.tag
                }.bind(to: viewModel.didTapBookmarkButton)
            
            editLabel.rx.tapGesture()
                .when(.recognized)
                .withUnretained(self)
                .bind { owner, _ in
                    if owner.editLabel.text == "완료" {
                        owner.bottomView.setAskingText("타투 업로드")
                        owner.bottomView.setAskButtonTag(1)
                    }

                    JHBPDispatchSystem.dispatch.multicastDelegate.invokeDelegates { delegate in
                        _ = delegate.notifyCellCollectionView()
                    }
                }

            bottomView.askButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.pushToEditVC()
                }

            viewModel.sections
                .drive(self.collectionView.rx.items(dataSource: dataSource))
            
            viewModel.shouldFillHeartButton
                .drive(with: self) { owner, shouldFill in
                    owner.switchHeartButton(shouldFill: shouldFill)
                }
            
            viewModel.bookmarkCountStringDriver
                .drive(bottomView.bookmarkCountLabel.rx.text)
            
            viewModel.serverErrorDriver
                .drive(with: self) { owner, _ in
                    let vc = OneButtonAlertViewController(viewModel: .init(content: "존재하지 않는 사용자거나 오류가 발생했습니다.", buttonText: "확인"))
                    owner.present(vc, animated: true)
                    owner.navigationController?.popViewController(animated: true)
                }
        
        // TODO: - postType별 id로 상세페이지 들어가기
//            viewModel.showDetailVCDriver
//                .drive(with: self) { owner, nextVCInfo in
//                    let postType = nextVCInfo.0
//                    let id = nextVCInfo.1
//                    let vc = OneButtonAlertViewController(viewModel: .init(content: "존재하지 않는 사용자거나 오류가 발생했습니다.", buttonText: "확인"))
//                    owner.present(vc, animated: true)
//                    owner.navigationController?.popViewController(animated: true)
//                }
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
                owner.navigationController?.pushViewController(TattooDetailViewController(viewModel: .init(tattooId: tattooId)), animated: true)
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
    private func switchHeartButton(shouldFill: Bool) {
        let heartImage = shouldFill ? UIImage(systemName: "heart.fill") : UIImage(named: "like")
        heartImage?.withRenderingMode(.alwaysOriginal).withTintColor(.white)

        bottomView.heartButton.setImage(heartImage, for: .normal)
        bottomView.heartButton.tag = shouldFill ? 1 : 0
    }

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
        bind(viewModel: viewModel)
        if !viewModel.isOwner {
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
}
