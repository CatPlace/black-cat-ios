//
//  BPContentSectionHeaderReactor.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/31.
//

import ReactorKit

final class BPContentSectionHeaderReactor: Reactor {
    typealias BPContentHeaderButtonType = BPContentSectionHeaderView.BPContentHeaderButtonType
    
    enum Action {
        case didTapProfile
        case didTapProduct
        case didTapReview
        case didTapInfo
    }
    
    enum Mutation {
        case selectedButton(BPContentHeaderButtonType)
    }

    struct State {
        @Pulse var selectedButton: BPContentHeaderButtonType
        
        init(selectedButton: BPContentHeaderButtonType = .profile) {
            self.selectedButton = .profile
        }
    }
    
    var initialState: State
    
    init(initialState: State) {
        self.initialState = initialState
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTapProfile:
            return .just(.selectedButton(.profile))
        case .didTapProduct:
            return .just(.selectedButton(.product))
        case .didTapReview:
            return .just(.selectedButton(.review))
        case .didTapInfo:
            return .just(.selectedButton(.info))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .selectedButton(let type):
            newState.selectedButton = type
            return newState
        }
    }
}
