//
//  BPContentCellReactor.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/31.
//

import ReactorKit

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
        var products: [BPProductModel] = []
        var reviews: [BPReviewModel] = []
        
        init(contentModel: BPContentModel) {
            self.contentModel = contentModel
        }
    }
    
    var initialState: State
    var provider: BPContentCellServiceProtocol = BPContentCellService()
    
    init(initialState: State) {
        self.initialState = initialState
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .initialize:
            return .concat([
                .just(.fetchProducts(provider.fetchProducts())),
                .just(.fetchReviews(provider.fetchReviews()))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .fetchProducts(let products):
            newState.products = products
            return newState
        case .fetchReviews(let reviews):
            newState.reviews = reviews
            return newState
        }
    }
}
