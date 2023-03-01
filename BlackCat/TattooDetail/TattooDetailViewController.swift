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
    deinit {
        disposeBag = DisposeBag()
        viewModel.disposeBag = DisposeBag()
    }
    var disposeBag = DisposeBag()
    enum Reusable {
        static let tattooDetailCell = ReusableCell<TattooDetailCell>()
        static let generCell = ReusableCell<GenreCell>()
    }
    
    // MARK: - Properties
    
    var viewModel: TattooDetailViewModel
    
    // MARK: - Binding
    
    private func bind(to viewModel: TattooDetailViewModel) {
        disposeBag.insert {
            rx.viewWillAppear
                .bind(to: viewModel.viewWillAppear)
            
            rx.viewWillDisappear
                .map { _ in () }
                .bind(to: viewModel.bookmarkTrigger)
            
            deleteLabel.rx.tapGesture()
                .when(.recognized)
                .withUnretained(self)
                .bind { owner, _ in
                    let vc = TwoButtonAlertViewController(viewModel: .init(type: .warningDelete([])))
                    vc.delegate = owner
                    owner.present(vc, animated: true)
                }
            
            tattooistProfileView.tattooProfileImageView.rx.tapGesture()
                .when(.recognized)
                .map { _ in () }
                .bind(to: viewModel.didTapProfileImageView)
            
            tattooistProfileView.reportImageView.rx.tapGesture()
                .when(.recognized)
                .withUnretained(self)
                .bind { owner, _ in
                    let vc = TwoButtonAlertViewController(viewModel: .init(type: .userReportwarning))
                    vc.delegate = owner
                    owner.present(vc, animated: true)
                }
            
            tattooistProfileView.tattooistNameLabel.rx.tapGesture()
                .when(.recognized)
                .map { _ in () }
                .bind(to: viewModel.didTapTattooistNameLabel)
            
            askBottomView.bookmarkView.rx.tapGesture()
                .when(.recognized)
                .withUnretained(self)
                .map { owner, _ in  owner.askBottomView.heartButton.tag }
                .bind(to: viewModel.didTapBookmarkButton)
            
            askBottomView.askButton.rx.tap
                .withUnretained(self)
                .map { owner, _ in owner.askBottomView.askButtonTag()}
                .bind(to: viewModel.didTapAskButton)
            
            viewModel.shouldFillHeartButton
                .drive(with: self) { owner, shouldFill in
                    owner.switchHeartButton(shouldFill: shouldFill)
                }
            
            viewModel.pushToTattooistDetailVC
                .drive(with: self) { owner, tattooistId in
                    let tattooistDetailVC = JHBusinessProfileViewController(viewModel: .init(tattooistId: tattooistId))
                    owner.navigationController?.pushViewController(tattooistDetailVC, animated: true)
                }
            
            viewModel.isOwnerDriver
                .drive(with: self) { owner, isOwner in
                    owner.updateAskBottomview(with: isOwner)
                    owner.deleteLabel.isHidden = !isOwner
                }
            
            viewModel.loginNeedAlertDriver
                .drive(with: self) { owner, _ in
                    let vc = LoginAlertViewController()
                    owner.present(vc, animated: true)
                }
            
            viewModel.tattooistNameLabelText
                .drive(tattooistProfileView.tattooistNameLabel.rx.text)
            
            viewModel.descriptionLabelText
                .drive(descriptionLabel.rx.text)
            
            viewModel.createDateString
                .drive(dateLabel.rx.text)
            
            viewModel.tattooistProfileImageUrlString
                .compactMap { URL(string: $0) }
                .drive(with: self) { owner, url in
                    Nuke.loadImage(with: url, into: owner.tattooistProfileView.tattooProfileImageView)
                }
            
            viewModel.imageCountDriver
                .drive(pageControl.rx.numberOfPages)
            
            viewModel.bookmarkCountStringDriver
                .drive(askBottomView.bookmarkCountLabel.rx.text)
            
            viewModel.tattooTitleStringDriver
                .drive(with: self) { owner, title in
                    owner.tattooTitle.text = title
                    owner.titleLabel.text = title
                }
            
            viewModel.genreCountDriver
                .drive(with: self) { owner, count in
                    owner.resizeGenreCollectionView(with: count)
                }
            
            viewModel.alertMessageDriver
                .drive(with: self) { owner, message in
                    owner.showOneButtonAlert(with: message)
                }
            
            viewModel.popViewDriver
                .drive(with: self) { owner, _ in
                    owner.navigationController?.popViewController(animated: true)
                }
        }
        
        viewModel.문의하기Driver
            .drive(with: self) { owner, _ in
                let vc = OneButtonAlertViewController(viewModel: .init(content: "준비중입니다.", buttonText: "확인"))
                owner.present(vc, animated: true)
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
    func resizeGenreCollectionView(with count: Int) {
        genreCollectionView.snp.updateConstraints {
            $0.width.equalTo(8 * (count - 1) + 60 * count)
        }
    }
    
    func showOneButtonAlert(with message: String) {
        let vc = OneButtonAlertViewController(viewModel: .init(content: message, buttonText: "확인"))
        present(vc, animated: true)
    }
    func updateAskBottomview(with isOwner: Bool) {
        askBottomView.setAskingText(isOwner ? "수정하기" : "문의하기")
        askBottomView.setAskButtonTag(isOwner ? 0 : 1)
    }
    
    private func switchHeartButton(shouldFill: Bool) {
        let heartImage = shouldFill ? UIImage(named: "heart.fill") : UIImage(named: "like")
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
        view.backgroundColor = .white
        hidesBottomBarWhenPushed = true
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
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBackgroundColor(color: .clear)
    }
    
    // MARK: - UIComponents
    
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()
    
    let titleLabel: UILabel = {
        $0.textColor = .white
        $0.font = .appleSDGoithcFont(size: 20, style: .bold)
        $0.text = "타투 제목입니다."
        return $0
    }(UILabel())
    
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
    
    func centerItemsInCollectionView(cellWidth: Double, numberOfItems: Double, spaceBetweenCell: Double, collectionView: UICollectionView) -> UIEdgeInsets {
        let totalWidth = cellWidth * numberOfItems
        let totalSpacingWidth = spaceBetweenCell * (numberOfItems - 1)
        let leftInset = (collectionView.frame.width - CGFloat(totalWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
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
        $0.font = .appleSDGoithcFont(size: 24, style: .bold)
        return $0
    }(UILabel())
    
    private let tattooistProfileView = TattooistProfileView()
    
    private let navigationBarDividerView: UIView = {
        $0.backgroundColor = .white
        return $0
    }(UIView())
    
    private let dividerView: UIView = {
        $0.backgroundColor = .black
        return $0
    }(UIView())
    
    private let descriptionLabel: UILabel = {
        $0.font = .appleSDGoithcFont(size: 16, style: .medium)
        $0.text = "내용 없음"
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    private let dateLabel: UILabel = {
        $0.font = .appleSDGoithcFont(size: 14, style: .regular)
        $0.textColor = .init(hex: "#666666FF")
        return $0
    }(UILabel())
    
    private let deleteLabel: UILabel = {
        $0.text = "삭제"
        $0.textColor = .white
        $0.font = .appleSDGoithcFont(size: 16, style: .regular)
        return $0
    }(UILabel())
    
    
    
    private let askBottomView = AskBottomView()
}

extension TattooDetailViewController {
    private var cellHeight: CGFloat { (500 * UIScreen.main.bounds.width) / 375 }
    
    private func setNavigationBar() {
        appendNavigationLeftBackButton()
        appendNavigationRightLabel(deleteLabel)
        appendNavigationLeftCustomView(titleLabel)
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
        
        [imageCollectionView, navigationBarDividerView, genreCollectionView, pageControl, tattooTitle, tattooistProfileView, dividerView, descriptionLabel, dateLabel].forEach { contentView.addSubview($0) }
        
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
        
        tattooistProfileView.snp.makeConstraints {
            $0.top.equalTo(tattooTitle.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(30)
        }
        
        dividerView.snp.makeConstraints {
            $0.top.equalTo(tattooistProfileView.snp.bottom).offset(20)
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
            $0.bottom.equalToSuperview().inset(150)
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

extension TattooDetailViewController: TwoButtonAlertViewDelegate {
    func didTapRightButton(type: TwoButtonAlertType) {
        
        dismiss(animated: true) { [weak self] in
            switch type {
            case .userReportwarning:
                let vc = OneButtonAlertViewController(viewModel: .init(content: "신고가 접수되었습니다", buttonText: "확인"))
                self?.present(vc, animated: true)
            case .warningDelete(_):
                self?.viewModel.deleteTrigger.accept(())
            default: break
            }
        }
    }
    
    func didTapLeftButton(type: TwoButtonAlertType) {
        dismiss(animated: true)
    }
    
    
}
