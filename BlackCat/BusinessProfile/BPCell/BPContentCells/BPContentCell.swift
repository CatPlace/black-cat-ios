//
//  BPContentCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import UIKit
import ReactorKit
import SnapKit
import BlackCatSDK

final class BPContentCell: BPBaseCollectionViewCell, View {
    typealias Reactor = BPContentCellReactor
    
    enum Reusable {
        static let profileCell = ReusableCell<BPProfileCell>()
        static let productCell = ReusableCell<BPProductCell>()
        static let reviewCell = ReusableCell<BPReviewCell>()
        static let priceInfoCell = ReusableCell<BPPriceInfoCell>()
    }
    
    enum BPContentType: CaseIterable {
        case profile, product, review, priceInfo
    }
    
    func bind(reactor: Reactor) {
        dispatch(reactor: reactor)
        render(reactor: reactor)
    }
    
    private func dispatch(reactor: Reactor) {
        productCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
        reviewCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
        profileCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
        priceInfoCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        reactor.action.onNext(.initialize)
    }
    
    private func render(reactor: Reactor) {
        
        reactor.state
            .filter { _ in reactor.currentState.contentModel.order == 0 }
            .map { $0.profiles }
            .bind(to: profileCollectionView.rx.items(Reusable.profileCell)) { [weak self] index, item, cell in
                guard let self = self else { return }
                self.setCollectionViewHidden(forType: .profile)
                
                cell.configureCell(with: item)
            }.disposed(by: self.disposeBag)
        
        reactor.state
            .filter { _ in reactor.currentState.contentModel.order == 1 }
            .map { $0.products }
            .bind(to: productCollectionView.rx.items(Reusable.productCell)) { [weak self] index, item, cell in
                guard let self = self else { return }
                self.setCollectionViewHidden(forType: .product)
                
                cell.configureCell(with: item)
            }.disposed(by: self.disposeBag)
        
        reactor.state
            .filter { _ in reactor.currentState.contentModel.order == 2 }
            .map { $0.reviews }
            .bind(to: reviewCollectionView.rx.items(Reusable.reviewCell)) { [weak self] index, item, cell in
                guard let self = self else { return }
                self.setCollectionViewHidden(forType: .review)
                
                cell.configureCell(with: item)
            }.disposed(by: self.disposeBag)
        
        reactor.state
            .filter { _ in reactor.currentState.contentModel.order == 3 }
            .map { $0.priceInfos }
            .bind(to: priceInfoCollectionView.rx.items(Reusable.priceInfoCell)) { [weak self] index, item, cell in
                guard let self = self else { return }
                self.setCollectionViewHidden(forType: .priceInfo)
                
                cell.configureCell(with: item)
            }.disposed(by: self.disposeBag)
    }
    
    func setCollectionViewHidden(forType type: BPContentType) {
        // ????????????? NOTE: - ???????????? ???????????? ??????
        [profileCollectionView,
         productCollectionView,
         reviewCollectionView,
         priceInfoCollectionView].forEach { $0.isHidden = true }
        
        if type == .profile { profileCollectionView.isHidden = false }
        else if type == .product { productCollectionView.isHidden = false }
        else if type == .review { reviewCollectionView.isHidden = false }
        else if type == .priceInfo { priceInfoCollectionView.isHidden = false }
    }
    
    // MARK: - Initialize
    override func initialize() {
        self.setUI()
    }
    
    // MARK: - UIComponents
    
    lazy var profileCollectionView: UICollectionView = {
        let layout = createLayout(forType: .profile)
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        cv.register(Reusable.profileCell)
        
        return cv
    }()
    
    lazy var productCollectionView: UICollectionView = {
        let layout = createLayout(forType: .product)
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        cv.register(Reusable.productCell)
        
        return cv
    }()
    
    lazy var reviewCollectionView: UICollectionView = {
        let layout = createLayout(forType: .review)
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        cv.register(Reusable.reviewCell)
        
        return cv
    }()
    
    lazy var priceInfoCollectionView: UICollectionView = {
        let layout = createLayout(forType: .priceInfo)
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        
        cv.register(Reusable.priceInfoCell)
        
        return cv
    }()
}

extension BPContentCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // ????????????? NOTE: - ????????????, ????????? ????????? ?????? ?????? refresh????????? ?????????????
        // NOTE: - delegateProxy??? ???????????? ????????? ???????????????.
        
        scrollView.bounces = scrollView.contentOffset.y >= 0
        
        print("scrollView \(scrollView.contentOffset.y)")
        
        BPDispatchSystem.dispatch.multicastDelegate.invokeDelegates { delegate in
            delegate.notifyViewController(offset: scrollView.contentOffset.y)
        }
        
    }
}
