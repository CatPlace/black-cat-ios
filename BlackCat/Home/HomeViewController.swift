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

        viewModel.categoryItems
            .drive(section1CollectionView.rx.items(
                cellIdentifier: HomeSection1Cell.identifier,
                cellType: HomeSection1Cell.self)
            ) { index, title, cell in
                cell.producerLabel.text = title
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        setUI()
        bind(to: viewModel)
    }

    // MARK: - UIComponents

    let leftTitleBarButtonItem: UIBarButtonItem = {
        let label = UILabel()
        label.text = "Black Cat"
        label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 32)

        return UIBarButtonItem(customView: label)
    }()
    let searchBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: nil)
    let heartBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: nil)

    let scrollView = UIScrollView()
    let contentView = UIView()
    let VStackView = UIStackView()
    
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

    let section1View = UIView()
    let section1TitleLabel = UILabel()
    lazy var section1CollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: section1CollectionViewFlowLayout
    )

    let section1CollectionViewFlowLayout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: 160, height: 217)

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
    private func setNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        navigationController?.navigationBar.layer.shadowRadius = 5.0
        navigationController?.navigationBar.layer.shadowOpacity = 0.05
        navigationController?.navigationBar.layer.masksToBounds = false
        navigationItem.leftBarButtonItem = leftTitleBarButtonItem
        navigationItem.rightBarButtonItems = [searchBarButtonItem, heartBarButtonItem]
    }

    private func setUI() {
        view.addSubview(scrollView)

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        scrollView.addSubview(contentView)

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        contentView.addSubview(VStackView)

        VStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        [categoryCollectionView, section1View].forEach { VStackView.addArrangedSubview($0) }

        VStackView.axis = .vertical
        VStackView.spacing = 0

        categoryCollectionView.snp.makeConstraints {
            let cellHeight = (UIScreen.main.bounds.width - (12 * 4) - 28) / 5
            $0.height.equalTo(cellHeight * 3 + (12 * 2) + 60)
        }
        categoryCollectionView.backgroundColor = .designSystem(.BackgroundSecondary)

        categoryCollectionView.register(
            HomeCategoryCell.self,
            forCellWithReuseIdentifier: HomeCategoryCell.identifier
        )

        section1View.snp.makeConstraints {
            $0.height.equalTo(260)
        }

        [section1TitleLabel, section1CollectionView].forEach { section1View.addSubview($0) }

        section1TitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(15)
            $0.leading.equalToSuperview().inset(20)
        }

        section1TitleLabel.text = "항목1"
        section1TitleLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)

        section1CollectionView.snp.makeConstraints {
            $0.top.equalTo(section1TitleLabel.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        section1CollectionView.register(
            HomeSection1Cell.self,
            forCellWithReuseIdentifier: HomeSection1Cell.identifier
        )
        section1CollectionView.isScrollEnabled = true
        section1CollectionView.isPagingEnabled = false
    }
}

