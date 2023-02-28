//
//  BookmarkTattooViewController.swift
//  BlackCat
//
//  Created by SeYeong on 2022/11/10.
//

import UIKit

import BlackCatSDK
import RxCocoa
import RxSwift
import SnapKit

class BookmarkPostViewController: UIViewController {

    let disposeBag = DisposeBag()
    enum Reusable {
        static let postCell = ReusableCell<SelectableImageCell>()
    }

    // MARK: - Properties

    let viewModel: BookmarkPostViewModel

    // MARK: - Binding

    private func bind(to viewModel: BookmarkPostViewModel) {
        rx.viewWillAppear
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .map { $0.row }
            .bind(to: viewModel.didSelectItem)
            .disposed(by: disposeBag)
        
        viewModel.postItems
            .drive(collectionView.rx.items(Reusable.postCell)) {  _, viewModel, cell in
                print("=========Tattoo Items==========")

                cell.bind(to: viewModel)
            }
            .disposed(by: disposeBag)
        
        viewModel.showWariningDeleteAlertDriver
            .drive(with: self) { owner, deletedIndexList in
                let vc = TwoButtonAlertViewController(viewModel: .init(type: .warningDelete(deletedIndexList)))
                vc.delegate = self
                owner.present(vc, animated: true)
            }.disposed(by: disposeBag)
        
        viewModel.showDeleteSuccessAlertDriver
            .drive(with: self) { owner, deletedIndexList in
                let vc = OneButtonAlertViewController(viewModel: .init(content: "삭제되었습니다.", buttonText: "확인"))
                owner.present(vc, animated: true)
            }.disposed(by: disposeBag)
        
        viewModel.showDeleteFailAlertDriver
            .drive(with: self) { owner, deletedIndexList in
                let vc = OneButtonAlertViewController(viewModel: .init(content: "삭제에 실패했습니다\n잠시후 다시 시도해주세요.", buttonText: "확인"))
                owner.present(vc, animated: true)
            }.disposed(by: disposeBag)
        
        // TODO: - postType별 id로 상세페이지 들어가기
        viewModel.showTattooDetailVCDriver
            .drive(with: self) { owner, tattooId in
                let vc = TattooDetailViewController(viewModel: .init(tattooId: tattooId))
                owner.navigationController?.pushViewController(vc, animated: true)
        }
        
        viewModel.showTattooistDetailVCDriver
            .drive(with: self) { owner, tattooistId in
                let vc = JHBusinessProfileViewController(viewModel: .init(tattooistId: tattooistId))
                owner.navigationController?.pushViewController(vc, animated: true)
        }
        
    }

    // MARK: - Function

    // MARK: - Initialize

    init(viewModel: BookmarkPostViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
        bind(to: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }

    // MARK: - UIComponents

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero,
                                  collectionViewLayout: collectionViewLayout)
        cv.register(Reusable.postCell)
        cv.showsVerticalScrollIndicator = false
        return cv
    }()

    private let collectionViewLayout: UICollectionViewLayout = {
        let minLineSpacing: CGFloat = 1
        let minInterSpacing: CGFloat = 1
        let itemWidth = (UIScreen.main.bounds.width - 3) / 3

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumLineSpacing = minLineSpacing
        layout.minimumInteritemSpacing = minInterSpacing
        layout.sectionInset = .init(top: 0, left: 0.5, bottom: 0, right: 0.5)
        return layout
    }()
    
    private func setUI() {
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension BookmarkPostViewController: TwoButtonAlertViewDelegate {
    func didTapRightButton(type: TwoButtonAlertType) {
        switch type {
        case .warningDelete(let shouldDeleteIndexList):
            viewModel.deleteTrigger.accept(shouldDeleteIndexList)
        default: break
        }
        
        dismiss(animated: true)
    }
    
    func didTapLeftButton(type: TwoButtonAlertType) {
        dismiss(animated: true)
    }
    

}

