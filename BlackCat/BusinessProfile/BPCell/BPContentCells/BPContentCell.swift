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
        
        reactor.action.onNext(.initialize)
    }
    
    private func render(reactor: Reactor) {
        
        reactor.state
            .filter { _ in reactor.currentState.contentModel.order == 0 }
            .map { $0.profiles }
            .bind(to: profileCollectionView.rx.items(Reusable.profileCell)) { [weak self] index, item, cell in
                guard let self = self else { return }
                self.setCollectionViewHidden(forType: .profile)
                print(" 👍 itme \(item)")
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
            .bind(to: priceInfoTableView.rx.items(Reusable.priceInfoCell)) { [weak self] index, item, cell in
                guard let self = self else { return }
                self.setCollectionViewHidden(forType: .priceInfo)
                
                cell.configureCell(with: item)
//                self.layoutIfNeeded()
                self.priceInfoTableView.beginUpdates()
                self.priceInfoTableView.endUpdates()

            }.disposed(by: self.disposeBag)
    }
    
    func setCollectionViewHidden(forType type: BPContentType) {
        // 🐻‍❄️ NOTE: - 알고리즘 리팩토링 가능
        [profileCollectionView,
         productCollectionView,
         reviewCollectionView,
         priceInfoTableView].forEach { $0.isHidden = true }
        
        if type == .profile { profileCollectionView.isHidden = false }
        else if type == .product { productCollectionView.isHidden = false }
        else if type == .review { reviewCollectionView.isHidden = false }
        else if type == .priceInfo { priceInfoTableView.isHidden = false }
    }
    
    // MARK: - Initialize
    override func initialize() {
        self.setUI()
    }
    
    // MARK: - UIComponents
    
    lazy var productCollectionView: UICollectionView = {
        let layout = createLayout(forType: .product)
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.backgroundColor = .white
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
    
    lazy var profileCollectionView: UICollectionView = {
        let layout = createLayout(forType: .profile)
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        cv.register(Reusable.profileCell)
        return cv
    }()
    
    lazy var priceInfoTableView: UITableView = {
        $0.separatorStyle = .none
        $0.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        $0.rowHeight = UITableView.automaticDimension
        $0.register(Reusable.priceInfoCell)
        
        return $0
    }(UITableView())
}

extension BPContentCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 🐻‍❄️ NOTE: - 막지말고, 차라리 당겨서 해당 셀을 refresh하는건 어떨까요?
        
        scrollView.bounces = scrollView.contentOffset.y >= 0
        
        print("scrollView \(scrollView.contentOffset.y)")
        BPDispatchSystem.dispatch.multicastDelegate.invokeDelegates { delegate in
            delegate.notifyViewController(offset: scrollView.contentOffset.y)
        }
    }
}
