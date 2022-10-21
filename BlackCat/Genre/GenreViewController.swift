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
        static let genreCell = ReusableCell<HomeTattooAlbumCell>()
    }

    // MARK: - Properties

    let viewModel = GenreViewModel()

    // MARK: - Binding

    // MARK: - Initializing

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - UIComponents

    let filterButtonItem: UIBarButtonItem = {
        let image = UIImage(systemName: "slider.horizontal.3")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        return UIBarButtonItem(image: image, style: .plain, target: self, action: nil)
    }()

    let heartBarButtonItem: UIBarButtonItem = {
        let image = UIImage(systemName: "heart")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        return UIBarButtonItem(image: image, style: .plain, target: self, action: nil)
    }()

    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero,
                                  collectionViewLayout: flowLayout)

        cv.register(Reusable.genreCell)

        cv.showsVerticalScrollIndicator = false
        return cv
    }()

    lazy var flowLayout: UICollectionViewLayout = {
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
        navigationItem.rightBarButtonItems = [heartBarButtonItem,
                                              filterButtonItem]
    }

    private func setUI() {
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
