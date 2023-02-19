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
import RxGesture
import SnapKit
import Nuke
final class TattooDetailViewController: UIViewController {

    let disposeBag = DisposeBag()
    enum Reusable {
        static let tattooDetailCell = ReusableCell<TattooDetailCell>()
        static let generCell = ReusableCell<GenreCell>()
    }

    // MARK: - Properties

    let viewModel: TattooDetailViewModel

    // MARK: - Binding

    private func bind(to viewModel: TattooDetailViewModel) {
        disposeBag.insert {
            rx.viewWillDisappear
                .map { _ in () }
                .bind(to: viewModel.bookmarkTrigger)

            tattooProfileImageView.rx.tapGesture()
                .when(.recognized)
                .map { _ in () }
                .bind(to: viewModel.didTapProfileImageView)

            askBottomView.bookmarkView.rx.tapGesture()
                .when(.recognized)
                .map { _ in  self.askBottomView.heartButton.tag }
                .bind(to: viewModel.didTapBookmarkButton)
            
            askBottomView.askButton.rx.tap
                .withUnretained(self)
                .map { owner, _ in owner.askBottomView.askButtonTag()}
                .bind(to: viewModel.didTapAskButton)
            
            tattooistNameLabel.rx.tapGesture()
                .when(.recognized)
                .map { _ in () }
                .bind(to: viewModel.didTapTattooistNameLabel)

            viewModel.shouldFillHeartButton
                .drive(with: self) { owner, shouldFill in
                    owner.switchHeartButton(shouldFill: shouldFill)
                }

            viewModel.pushToTattooistDetailVC
                .drive(with: self) { owner, _ in
                    let tattooistDetailVC = JHBusinessProfileViewController(viewModel: .init(tattooistId: -1)) // TODO: - 타투이스트 id 내려주기
                    owner.navigationController?.pushViewController(tattooistDetailVC, animated: true)
                }

            viewModel.isOwnerDriver
                .drive(with: self) { owner, isOwner in
                    owner.updateAskBottomview(with: isOwner)
                }

            viewModel.isGuestDriver
                .drive(with: self) { owner, isGuest in
                    owner.askBottomView.bookmarkView.isHidden = isGuest
                }

            viewModel.tattooistNameLabelText
                .drive(tattooistNameLabel.rx.text)

            viewModel.descriptionLabelText
                .drive(descriptionLabel.rx.text)

            viewModel.createDateString
                .drive(dateLabel.rx.text)

            viewModel.tattooistProfileImageUrlString
                .compactMap { URL(string: $0) }
                .drive(with: self) { owner, url in
                    Nuke.loadImage(with: url, into: owner.tattooProfileImageView)
                }

            viewModel.imageCountDriver
                .drive(pageControl.rx.numberOfPages)
        }
        viewModel.문의하기Driver
            .drive { _ in
                print("문의하기 탭")
            }.disposed(by: disposeBag)
        
        viewModel.수정하기Driver
            .drive(with: self) { owner, tattooModel in
                owner.navigationController?.pushViewController(ProductEditViewController(viewModel: .init(tattoo: tattooModel)), animated: true)
            }.disposed(by: disposeBag)

        viewModel.tattooimageUrls
            .drive(imageCollectionView.rx.items) { cv, row, data in
                let cell = cv.dequeue(Reusable.tattooDetailCell, for: IndexPath(row: row, section: 0))

                cell.configure(with: data)

                return cell
            }.disposed(by: disposeBag)

        viewModel.tattooCategories
            .drive(genreCollectionView.rx.items) { cv, row, data in
                let cell = cv.dequeue(Reusable.generCell, for: IndexPath(row: row, section: 0))
                cell.configure(with: data)
                return cell
            }.disposed(by: disposeBag)
    }

    // function
    func updateAskBottomview(with isOwner: Bool) {
        askBottomView.setAskingText(isOwner ? "수정하기" : "문의하기")
        askBottomView.setAskButtonTag(isOwner ? 0 : 1)

    }

    private func switchHeartButton(shouldFill: Bool) {
        let heartImage = shouldFill ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        heartImage?.withRenderingMode(.alwaysOriginal).withTintColor(.white)

        askBottomView.heartButton.setImage(heartImage, for: .normal)

        askBottomView.heartButton.tag = shouldFill ? 1 : 0
    }

    func edgeInset(cellWidth: CGFloat, numberOfCells: Int) -> UIEdgeInsets {
        let numberOfCells = floor(view.frame.size.width / cellWidth)
        let edgeInsets = (view.frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells + 1)

        return .init(top: 0, left: edgeInsets, bottom: 0, right: edgeInsets)
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

    private lazy var imageCollectionView: UICollectionView = {
        $0.register(Reusable.tattooDetailCell)
        $0.isPagingEnabled = true
        $0.delegate = self
        $0.showsHorizontalScrollIndicator = false
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: flowLayout))

    private lazy var genreFlowLayout: UICollectionViewLayout = {
        $0.minimumLineSpacing = 8.0
        $0.scrollDirection = .horizontal
        let width: CGFloat = 60
        let height: CGFloat = 28
        $0.itemSize = .init(width: width, height: height)
        return $0
    }(UICollectionViewFlowLayout())

    private lazy var genreCollectionView: UICollectionView = {
        $0.register(Reusable.generCell)
        $0.backgroundColor = .clear
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: genreFlowLayout))

    private let pageControl: CHIPageControlJaloro = {
        $0.currentPageTintColor = .init(hex: "#333333FF")
        $0.tintColor = .init(hex: "#FFFFFFFF")?.withAlphaComponent(0.7)
        $0.radius = 3
        $0.elementWidth = 30
        $0.padding = 8
        return $0
    }(CHIPageControlJaloro())

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

    private let navigationBarDividerView: UIView = {
        $0.backgroundColor = .white
        return $0
    }(UIView())

    private let dividerView: UIView = {
        $0.backgroundColor = .black
        return $0
    }(UIView())

    private let dateLabel: UILabel = {
        $0.font = .systemFont(ofSize: 14)
        $0.tintColor = .init(hex: "#666666FF")
        $0.text = "2022년 12월 27일"
        return $0
    }(UILabel())

    private let descriptionLabel: UILabel = {
        $0.font = .systemFont(ofSize: 14)
        $0.tintColor = .init(hex: "#666666FF")
        $0.text = " 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n 요즘은 이게 대세입니다.\n"
        $0.numberOfLines = 0
        return $0
    }(UILabel())

    private let askBottomView = AskBottomView()
}

extension TattooDetailViewController {
    private var cellHeight: CGFloat { (500 * UIScreen.main.bounds.width) / 375 }

    private func setNavigationBar() {
        self.navigationController?.navigationBar.backgroundColor = .clear
        appendNavigationLeftBackButton()
        appendNavigationLeftLabel(title: "타투 제목", color: .white)
    }

    private func setUI() {
        view.backgroundColor = .clear
        view.addSubview(scrollView)

        scrollView.contentInsetAdjustmentBehavior = .never

        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.bottom.equalToSuperview()
        }

        scrollView.addSubview(contentView)

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        [imageCollectionView, navigationBarDividerView, genreCollectionView, pageControl, tattooTitle, tattooProfileImageView, tattooistNameLabel, dividerView, descriptionLabel, dateLabel].forEach { contentView.addSubview($0) }

        imageCollectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(cellHeight)
        }

        navigationBarDividerView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(94)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }

        genreCollectionView.snp.makeConstraints {
            $0.top.equalTo(navigationBarDividerView.snp.bottom).offset(15)
//            $0.leading.trailing.equalToSuperview()
            $0.width.equalTo(196)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(60)
        }

        pageControl.snp.makeConstraints {
            $0.height.equalTo(6)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(imageCollectionView.snp.bottom).offset(-10)
        }

        tattooTitle.snp.makeConstraints {
            $0.top.equalTo(imageCollectionView.snp.bottom).offset(30)
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

        dividerView.snp.makeConstraints {
            $0.top.equalTo(tattooProfileImageView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(dividerView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(30)
        }

        dateLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(30)
            $0.bottom.equalToSuperview().inset(60)
        }

        view.addSubview(askBottomView)

        askBottomView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(28)
            $0.height.equalTo(60)
        }
    }
}

extension TattooDetailViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let width = UIScreen.main.bounds.width
        let currentPage = Int(offset / width)

        pageControl.set(progress: currentPage, animated: true)
    }
}
