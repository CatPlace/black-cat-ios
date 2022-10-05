//
//  HomeViewController.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/05.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

class HomeViewController: UIViewController {

    // MARK: - Properties
    let disposeBag = DisposeBag()
    let viewModel = HomeViewModel()

    // MARK: - Binding

    private func bind(to viewModel: HomeViewModel) {
        viewModel.categoryItems
            .drive(categoryCollectionView.rx.items(
                cellIdentifier: HomeCategoryCell.identifier,
                cellType: HomeCategoryCell.self)
            ) { index, title, cell in
                cell.categoryTitleLabel.text = title
                //            cell.bind(to: viewModel)
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        bind(to: viewModel)
    }

    // MARK: - UIComponents
    
    lazy var categoryCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: categoryCollectionViewFlowLayout
    )
    let categoryCollectionViewFlowLayout: UICollectionViewLayout = {
        let spacing: CGFloat = 12
        let itemWidth = (UIScreen.main.bounds.width - (spacing * 4) - 28) / 5

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.sectionInset = UIEdgeInsets(top: 30, left: 14, bottom: 30, right: 14)

        return layout
    }()

    private func categoryCellHeight() -> CGFloat {
        let spacing: CGFloat = 12
        let topInset: CGFloat = 30
        let bottomInset: CGFloat = 30

        return (UIScreen.main.bounds.width - (spacing * 2) - (topInset + bottomInset)) / 3
    }
}

extension HomeViewController {
    private func setUI() {
        view.addSubview(categoryCollectionView)

        categoryCollectionView.snp.makeConstraints {
            let cellHeight = (UIScreen.main.bounds.width - (12 * 4) - 28) / 5
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(cellHeight * 3 + (12 * 2) + 60)
        }
        categoryCollectionView.backgroundColor = .red

        categoryCollectionView.register(
            HomeCategoryCell.self,
            forCellWithReuseIdentifier: HomeCategoryCell.identifier
        )
    }
}

