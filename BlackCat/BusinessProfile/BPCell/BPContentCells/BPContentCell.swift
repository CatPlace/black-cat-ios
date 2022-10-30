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
            .bind(to: productCollectionView.rx.items(Reusable.productCell)) {
                index, item, cell in
                self.reviewCollectionView.isHidden = true
                self.productCollectionView.isHidden = false
                
                cell.configureCell(with: item)
            }.disposed(by: self.disposeBag)
        
        reactor.state
            .filter { _ in reactor.currentState.contentModel.order == 2 }
            .map { $0.reviews }
            .bind(to: reviewCollectionView.rx.items(Reusable.reviewCell)) {
                index, item, cell in
                self.reviewCollectionView.isHidden = false
                self.productCollectionView.isHidden = true
                
                cell.configureCell(with: item)
            }.disposed(by: self.disposeBag)
    }
    
    func isHiddenCollectionView(forType: Reusable) { }
    
    // MARK: - Initialize
    override func initialize() {
        setUI()
        
        BPDispatchSystem.dispatch.multicastDelegate.addDelegate(self)
    }
    
    // MARK: - UIComponents
    
    lazy var productCollectionView: UICollectionView = {
        let layout = createLayout()
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.register(Reusable.productCell)
        return cv
    }()
    
    lazy var reviewCollectionView: UICollectionView = {
        let layout = createLayout()
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.contentInsetAdjustmentBehavior = .never
        cv.register(Reusable.reviewCell)
        return cv
    }()
}

extension BPContentCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.bounces = scrollView.contentOffset.y > 0
        
        print("scrollView \(scrollView.contentOffset.y)")
        BPDispatchSystem.dispatch.multicastDelegate.invokeDelegates { delegate in
            delegate.notifyViewController(offset: scrollView.contentOffset.y)
        }
    }
}

extension BPContentCell: BPMulticastDelegate {
    
    func notifyCellCollectionView(value: Bool) {
        
        reviewCollectionView.isScrollEnabled = value
    }
}
