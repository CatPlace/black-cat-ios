//
//  TattooDetailViewController.swift
//  BlackCat
//
//  Created by SeYeong on 2022/12/27.
//

import UIKit

import BlackCatSDK
import RxCocoa
import RxSwift
import SnapKit

final class TattooDetailViewController: UIViewController {

    let disposeBag = DisposeBag()
    enum Reusable {
        static let tattooDetailCell = ReusableCell<TattooDetailCell>()
    }

    // MARK: - Properties

    let viewModel: TattooDetailViewModel

    // MARK: - Binding

    private func bind(to viewModel: TattooDetailViewModel) {
        pageControl.numberOfPages = viewModel.imageURLStrings.count

        disposeBag.insert {
            askButton.rx.tap
                .bind(to: viewModel.didTapAskButton)

            heartButton.rx.tap
                .bind(to: viewModel.didTapBookmarkButton)

            viewModel.shouldFillHeartButton
                .drive(with: self) { owner, shouldFill in
                    owner.switchHeartButton(shouldFill: shouldFill)
                }
        }
    }

    // function

    private func switchHeartButton(shouldFill: Bool) {
        let heartImage = shouldFill ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        heartImage?.withRenderingMode(.alwaysOriginal).withTintColor(.white)

        heartButton.setImage(heartImage, for: .normal)
    }

    // MARK: - Initialize

    init(viewModel: TattooDetailViewModel) {
        self.viewModel = viewModel

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
        bind(to: viewModel)
    }

    // MARK: - UIComponents

    private let scrollView = UIScrollView()

    private let contentView = UIView()

    private lazy var flowLayout: UICollectionViewLayout = {
        $0.minimumLineSpacing = 0.0
        $0.minimumInteritemSpacing = 0.0
        $0.scrollDirection = .horizontal
        let width = UIScreen.main.bounds.width
        let height: CGFloat = cellHeight
        $0.itemSize = .init(width: width, height: height)
        return $0
    }(UICollectionViewFlowLayout())

    private lazy var collectionView: UICollectionView = {
        $0.register(Reusable.tattooDetailCell)
        $0.isPagingEnabled = true
        $0.dataSource = self
        $0.delegate = self
        $0.showsHorizontalScrollIndicator = false
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: flowLayout))

    private let pageControl: CHIPageControlJaloro = {
        $0.currentPageTintColor = .init(hex: "#333333FF")
        $0.tintColor = .init(hex: "#FFFFFFFF")?.withAlphaComponent(0.7)
        $0.radius = 3
        $0.elementWidth = 30
        $0.padding = 8
        return $0
    }(CHIPageControlJaloro())

    private let shareRightBarButtonItem: UIBarButtonItem = {
        let image = UIImage(systemName: "square.and.arrow.up")?.withTintColor(.white)
        $0.image = image
        return $0
    }(UIBarButtonItem())

    private let tattooTitle: UILabel = {
        $0.text = "타투 제목"
        return $0
    }(UILabel())

    private let tattooProfileImageView: UIImageView = {
        $0.layer.cornerRadius = 15
        $0.clipsToBounds = true
        $0.backgroundColor = .lightGray
        return $0
    }(UIImageView())

    private let tattooistNameLabel: UILabel = {
        $0.font = .systemFont(ofSize: 16)
        $0.tintColor = .black
        $0.text = "김타투"
        return $0
    }(UILabel())

    private let dateLabel: UILabel = {
        $0.font = .systemFont(ofSize: 14)
        $0.tintColor = .init(hex: "#666666FF")
        $0.text = "2022년 12월 27일"
        return $0
    }(UILabel())

    private let descriptionLabel: UILabel = {
        $0.font = .systemFont(ofSize: 14)
        $0.tintColor = .init(hex: "#666666FF")
        $0.text = " 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n "
        $0.numberOfLines = 0
        return $0
    }(UILabel())

    private let askButton: UIButton = {
        $0.setTitle("문의하기", for: .normal)
        $0.backgroundColor = .init(hex: "#333333FF")
        $0.layer.cornerRadius = 20
        return $0
    }(UIButton())

    private let bookmarkView: UIView = {
        $0.backgroundColor = .init(hex: "#333333FF")
        $0.layer.cornerRadius = 20
        return $0
    }(UIView())

    private let heartButton: UIButton = {
        let heartImage = UIImage(systemName: "heart")?.withTintColor(.white).withRenderingMode(.alwaysOriginal)
        $0.setImage(heartImage, for: .normal)
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIButton())

    private let bookmarkCountLabel: UILabel = {
        $0.font = .systemFont(ofSize: 18)
        $0.adjustsFontSizeToFitWidth = true
        $0.textColor = .white
        $0.text = "25"
        return $0
    }(UILabel())
}

extension TattooDetailViewController {
    private var cellHeight: CGFloat { (500 * UIScreen.main.bounds.width) / 375 }

    private func setNavigationBar() {
        self.navigationItem.rightBarButtonItem = shareRightBarButtonItem
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

        [collectionView, pageControl, tattooTitle, tattooProfileImageView, tattooistNameLabel, dateLabel, descriptionLabel].forEach { contentView.addSubview($0) }

        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(cellHeight)
        }

        pageControl.snp.makeConstraints {
            $0.height.equalTo(6)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(collectionView.snp.bottom).offset(-10)
        }

        tattooTitle.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(30)
        }

        tattooProfileImageView.snp.makeConstraints {
            $0.top.equalTo(tattooTitle.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(30)
            $0.width.height.equalTo(30)
        }

        tattooistNameLabel.snp.makeConstraints {
            $0.leading.equalTo(tattooProfileImageView.snp.trailing).offset(5)
            $0.centerY.equalTo(tattooProfileImageView)
        }

        dateLabel.snp.makeConstraints {
            $0.top.equalTo(tattooProfileImageView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(30)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.bottom.equalToSuperview().inset(60)
        }

        [askButton, bookmarkView].forEach { view.addSubview($0) }

        bookmarkView.snp.makeConstraints {
            $0.width.equalTo(72)
            $0.height.equalTo(60)
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(28)
        }

        askButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalTo(bookmarkView.snp.leading).offset(-12)
            $0.height.equalTo(60)
            $0.bottom.equalToSuperview().inset(28)
        }

        [heartButton, bookmarkCountLabel].forEach { bookmarkView.addSubview($0) }

        heartButton.snp.makeConstraints {
            $0.leading.equalTo(14)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(20)
            $0.height.equalTo(18)
        }

        bookmarkCountLabel.snp.makeConstraints {
            $0.leading.equalTo(heartButton.snp.trailing).offset(5)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(14)
        }
    }
}

extension TattooDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return viewModel.imageURLStrings.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(Reusable.tattooDetailCell, for: indexPath)
        cell.configure(with: viewModel.imageURLStrings[indexPath.row])

        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let width = UIScreen.main.bounds.width
        let currentPage = Int(offset / width)

        pageControl.set(progress: currentPage, animated: true)
    }
}