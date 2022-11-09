//
//  GenreViewController.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/21.
//

import UIKit

import BlackCatSDK
import RxCocoa
import RxSwift
import SnapKit

class GenreViewController: UIViewController {

    let disposeBag = DisposeBag()
    enum Reusable {
        static let genreCell = ReusableCell<CommonFullImageCell>()
    }

    // MARK: - Properties

    let viewModel = GenreViewModel()
    let genreTitle: String

    // MARK: - Binding

    private func bind() {

        // MARK: - Action

        rx.viewWillAppear
            .map { _ in () }
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)

        backButtonItem.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        dropDown.rx.itemSelected
            .map { $0.row }
            .bind(to: viewModel.selectedDropDownItemRow)
            .disposed(by: disposeBag)

        // MARK: - State

        viewModel.dropDownItems
            .drive(with: self) { owner, items in
                owner.dropDown.configure(with: items)
            }
            .disposed(by: disposeBag)

        viewModel.categoryItems
            .drive(collectionView.rx.items(Reusable.genreCell)) { _, viewModel, cell in
                cell.bind(to: viewModel)
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Initializing

    init(genreTitle: String) {
        self.genreTitle = genreTitle

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        setUI()
        bind()
    }

    // MARK: - UIComponents
    private let dropDown: CategoryPaperView = {
        let view = CategoryPaperView()
        view.presentStyle = .dissolveAtCenter
        return view
    }()

    private let backButtonItem: UIBarButtonItem = {
        let image = UIImage(systemName: "chevron.backward")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        return UIBarButtonItem(image: image, style: .plain, target: self, action: nil)
    }()

    private lazy var dropDownItem: UIBarButtonItem = {
        return UIBarButtonItem(customView: dropDown)
    }()

    private let filterButtonItem: UIBarButtonItem = {
        let image = UIImage(systemName: "slider.horizontal.3")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        return UIBarButtonItem(image: image, style: .plain, target: self, action: nil)
    }()

    private let heartBarButtonItem: UIBarButtonItem = {
        let image = UIImage(systemName: "heart")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        return UIBarButtonItem(image: image, style: .plain, target: self, action: nil)
    }()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero,
                                  collectionViewLayout: flowLayout)

        cv.register(Reusable.genreCell)

        cv.showsVerticalScrollIndicator = false
        return cv
    }()

    private lazy var flowLayout: UICollectionViewLayout = {
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

extension GenreViewController {
    private func setNavigationBar() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItems = [backButtonItem, dropDownItem]
        navigationItem.rightBarButtonItems = [heartBarButtonItem, filterButtonItem]
    }

    private func setUI() {
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
