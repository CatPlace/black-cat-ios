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

class BookmarkTattooViewController: UIViewController {

    let disposeBag = DisposeBag()
    enum Reusable {
        static let tattooCell = ReusableCell<BMTattooCell>()
    }

    // MARK: - Properties

    let viewModel: BookmarkTattooViewModel

    // MARK: - Binding

    private func bind(to viewModel: BookmarkTattooViewModel) {
        rx.viewDidLoad
            .bind(to: viewModel.viewDidLoad)
            .disposed(by: disposeBag)

        rx.viewWillDisappear
            .map { _ in () }
            .bind(to: viewModel.viewWillDisappear)
            .disposed(by: disposeBag)

        collectionView.rx.itemSelected
            .map { $0.row }
            .bind(to: viewModel.didSelectItem)
            .disposed(by: disposeBag)

        viewModel.tattooItems
            .drive(collectionView.rx.items(Reusable.tattooCell)) { [weak self] _, viewModel, cell in
                print("=========Tattoo Items==========")
                self?.viewModel.editMode
                    .map { $0 == .normal }
                    .bind(to: viewModel.editModeIsNormal)
                    .disposed(by: self!.disposeBag)

                cell.bind(to: viewModel)
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Function

    // MARK: - Initialize

    init(viewModel: BookmarkTattooViewModel) {
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
        cv.register(Reusable.tattooCell)
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
}

extension BookmarkTattooViewController {
    private func setUI() {
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(5)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
