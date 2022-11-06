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
        case didTapTextformatSize
    }
    
    enum Mutation {
        case isDismiss
        case openPhotoLibrary
        case isShowingFormatSizeView
    }
    
    struct State {
        var isDismiss = false
        var isOpenPhotoLibrary = false
        var isShowingFormatSizeView = false
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
        case .didTapTextformatSize:
            return .just(.isShowingFormatSizeView)
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
        case .isShowingFormatSizeView:
            newState.isShowingFormatSizeView = !currentState.isShowingFormatSizeView
            return newState
        }
    }
}
