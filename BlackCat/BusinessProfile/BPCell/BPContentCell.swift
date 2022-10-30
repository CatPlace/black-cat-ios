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

final class BPContentCell: BPBaseCell, View, UIScrollViewDelegate {
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
        reactor.action.onNext(.initialize)
    }
    
    private func render(reactor: Reactor) {
        
    }
    
    // MARK: - Initialize
    override func initialize() {
        setUI()
    }
    
    // MARK: - UIComponents
    
    lazy var productCollectionView: UICollectionView = {
        let layout = createLayout()
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.rx.setDelegate(self).disposed(by: self.disposeBag)
        
        cv.register(Reusable.productCell)
        
        
        return cv
    }()
    
    lazy var reivewCollectionView: UICollectionView = {
        let layout = createLayout()
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.rx.setDelegate(self).disposed(by: self.disposeBag)
        
        cv.register(Reusable.reviewCell)
        return cv
    }()
}

final class BPContentCellReactor: Reactor {
    enum Action {
        case initialize
    }
    
    enum Mutation {
        /** 작품보기 */ case fetchProducts([BPProductModel])
        /** 후기 */ case fetchReviews([BPReviewModel])
    }
    
    struct State {
        var contentModel: BPContentModel
        
        init(contentModel: BPContentModel) {
            self.contentModel = contentModel
        }
    }
    
    var initialState: State
    
    init(initialState: State) {
        self.initialState = initialState
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .initialize:
            return .just(.fetchProducts([]))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .fetchProducts(let products):
            return newState
        case .fetchReviews(let reviews):
            return newState
        }
    }
}

