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
    // MARK: - Properties
    var disposeBag = DisposeBag()
    enum Reusable {
        static let tattooDetailCell = ReusableCell<TattooDetailCell>()
        static let generCell = ReusableCell<GenreCell>()
    }
    var cellWidths: [CGFloat] = []
    
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
            
            scrollView.rx.contentOffset
                .map { $0.y }
                .bind(with: self) { owner, offsetY in
                    owner.scrollView.bounces = offsetY > 0
                }
            
            viewModel.askBottomViewModel.didTapBookmarkButton
                .withUnretained(self)
                .map { owner, _ in  owner.askBottomView.heartButton.tag }
                .bind(to: viewModel.didTapBookmarkButton)
            
            viewModel.askBottomViewModel.didTapAskButton
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
            
            viewModel.alertMessageDriver
                .drive(with: self) { owner, message in
                    owner.showOneButtonAlert(with: message)
                }
            
            viewModel.popViewDriver
                .drive(with: self) { owner, _ in
                    owner.navigationController?.popViewController(animated: true)
                }
            
            viewModel.priceDriver
                .drive(priceLabel.rx.text)
        }
        
        imageCollectionView.rx.contentOffset
            .map { $0.x }
            .withUnretained(self)
            .map { owner, x in Int(round(x / owner.view.frame.width)) }
            .distinctUntilChanged()
            .withUnretained(self)
            .bind { owner, offsetX in
                owner.pageControl.set(progress: offsetX, animated: true)
            }.disposed(by: disposeBag)

        
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
        
        viewModel.tattooCategories
            .filter { $0.count > 0 }
            .drive(with: self) { owner, genres in
                var width: CGFloat = 0
                owner.cellWidths = genres.map { CGFloat($0.count) * 13 + 28 }
                width = owner.cellWidths.reduce(0) { $0 + $1 }
                width += CGFloat(genres.count - 1) * 8
                owner.genreCollectionView.snp.updateConstraints {
                    $0.width.equalTo(width)
                }
            }.disposed(by: disposeBag)
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
        askBottomView = .init(viewModel: viewModel.askBottomViewModel)
        
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
        setNavigationBackgroundColor(color: .init(hex: "#333333FF"))
    }
    
    // MARK: - UIComponents
    
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()
    
    private let gradientView: UIView = {
        $0.setGradient(startColor: .black, endColor: .clear, startPoint: .topCenter, endPoint: .bottomCenter)
        return $0
    }(UIView(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 120)))
    
    let titleLabel: UILabel = {
        $0.textColor = .white
        $0.font = .appleSDGoithcFont(size: 20, style: .bold)
        $0.adjustsFontSizeToFitWidth = true
        return $0
    }(UILabel(frame: .init(x: 0, y: 0, width: 200, height: 30)))
    
    let priceLabel: UILabel = {
        $0.font = .appleSDGoithcFont(size: 24, style: .bold)
        $0.adjustsFontSizeToFitWidth = true
        $0.textColor = .init(hex: "#7210A0FF")
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
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: flowLayout))
    
    private lazy var genreFlowLayout: UICollectionViewLayout = {
        $0.minimumLineSpacing = 8.0
        $0.scrollDirection = .horizontal
        let width: CGFloat = 150
        let height: CGFloat = 28
        $0.estimatedItemSize = .init(width: width, height: height)
        return $0
    }(UICollectionViewFlowLayout())
    
    private lazy var genreCollectionView: UICollectionView = {
        $0.register(Reusable.generCell)
        $0.backgroundColor = .clear
        $0.delegate = self
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
        $0.adjustsFontSizeToFitWidth = true
        $0.font = .appleSDGoithcFont(size: 24, style: .bold)
        return $0
    }(UILabel())
    
    private let tattooistProfileView = TattooistProfileView()
    
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
    
    private let askBottomView: AskBottomView
}

extension TattooDetailViewController {
    private var cellHeight: CGFloat { UIScreen.main.bounds.width }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setNavigationBar() {
        appendNavigationLeftBackButton()
        appendNavigationRightLabel(deleteLabel)
        appendNavigationLeftCustomView(titleLabel)
    }
    
    private func setUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        [imageCollectionView, genreCollectionView, pageControl, tattooTitle, priceLabel, dividerView, tattooistProfileView, descriptionLabel, dateLabel].forEach { contentView.addSubview($0) }
        
        imageCollectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(cellHeight)
        }
        
        genreCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.width.equalTo(300)
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
            $0.leading.trailing.equalToSuperview().inset(30)
        }
        
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(tattooTitle.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(30)
        }
        
        tattooistProfileView.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(15)
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
        
        [gradientView, askBottomView].forEach { view.addSubview($0) }
        
        gradientView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(120)
        }
        
        askBottomView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(90)
        }
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

extension TattooDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: cellWidths[indexPath.row], height: 28)
    }
}
