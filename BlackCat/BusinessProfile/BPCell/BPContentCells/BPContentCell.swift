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

final class BPContentCell: BPBaseCell, View {
    typealias Reactor = BPContentCellReactor
    
    enum Reusable {
        static let reviewCell = ReusableCell<BPReviewCell>()
        static let productCell = ReusableCell<BPProductCell>()
    }
    
    enum BPContentType: CaseIterable {
        case profile, product, review, info
    }
    
    func bind(reactor: Reactor) {
        dispatch(reactor: reactor)
        render(reactor: reactor)
    }
    
    private func dispatch(reactor: Reactor) {
        productCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
        reviewCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        reactor.action.onNext(.initialize)
    }
    
    private func render(reactor: Reactor) {
        
        reactor.state
            .filter { _ in reactor.currentState.contentModel.order == 1 }
            .map { $0.products }
            .bind(to: productCollectionView.rx.items(Reusable.productCell)) { [weak self]
                index, item, cell in
                guard let self = self else { return }
                self.setCollectionViewHidden(forType: .product)
                
                cell.configureCell(with: item)
            }.disposed(by: self.disposeBag)
        
        reactor.state
            .filter { _ in reactor.currentState.contentModel.order == 2 }
            .map { $0.reviews }
            .bind(to: reviewCollectionView.rx.items(Reusable.reviewCell)) { [weak self]
                index, item, cell in
                guard let self = self else { return }
                self.setCollectionViewHidden(forType: .review)
                
                cell.configureCell(with: item)
            }.disposed(by: self.disposeBag)
    }
    
    func setCollectionViewHidden(forType type: BPContentType) {
        [productCollectionView, reviewCollectionView].forEach { $0.isHidden = true }
        
        if type == .profile { }
        else if type == .product { productCollectionView.isHidden = false }
        else if type == .review { reviewCollectionView.isHidden = false }
        else if type == .info { }
    }
    
    // MARK: - Initialize
    override func initialize() {
        setUI()
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
