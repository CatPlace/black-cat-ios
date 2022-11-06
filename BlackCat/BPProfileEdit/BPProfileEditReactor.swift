//
//  BPProfileEditReactor.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/05.
//

import ReactorKit

final class BPProfileEditReactor: Reactor {
    enum Action {
        case didTapCloseItem
        case didTapPhotoItem
    }
    
    enum Mutation {
        case isDismiss
        case openPhotoLibrary
    }
    
    struct State {
        var isDismiss = false
        var isOpenPhotoLibrary = false
    }
    
    var initialState: State
    var provider: BPProfileEditServiceProtocol
    
    init(provider: BPProfileEditServiceProtocol = BPProfileEditServiceProvider()) {
        self.provider = provider
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTapCloseItem:
            return .just(.isDismiss)
        case .didTapPhotoItem:
            return .just(.openPhotoLibrary)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .isDismiss:
            newState.isDismiss = true
            return newState
        case .openPhotoLibrary:
            newState.isOpenPhotoLibrary = true
            return newState
        }
    }
}
