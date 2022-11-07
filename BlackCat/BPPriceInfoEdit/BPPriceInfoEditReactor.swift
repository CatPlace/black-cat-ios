//
//  BPPriceInfoEditReactor.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/05.
//

import ReactorKit
import RxRelay

final class BPPriceInfoEditReactor: Reactor {
    enum Action {
        case didTapCloseItem
        case didTapPhotoItem
        case didTapConfirmItem(String)
    }
    
    enum Mutation {
        case isDismiss
        case openPhotoLibrary
        case sendProfile(String)
    }
    
    struct State {
        var isDismiss = false
        @Pulse var isOpenPhotoLibrary = false
        
        var dataSource: [BPPriceInfoEditModel]
        
        init(dataSource: [BPPriceInfoEditModel]) {
            self.dataSource = dataSource
        }
    }
    
    var initialState: State
    var provider: BPPriceInfoEditServiceProtocol
    
    init(provider: BPPriceInfoEditServiceProtocol = BPPriceInfoEditService()) {
        self.provider = provider
        self.initialState = State(dataSource: [.init(row: 0, type: .text, input: "처음")])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTapCloseItem:
            return .just(.isDismiss)
        case .didTapPhotoItem:
            return .just(.openPhotoLibrary)
        case .didTapConfirmItem(let string):
            provider.priceEditStringService.convertToArray(string)
            return .just(.sendProfile(string))
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
        case .sendProfile(let string):
            // NOTE: - 서버로 보내기
            return newState
//        case .appendImage(let image):
//            var newValue = currentState.dataSource
//
//            newValue.append(BehaviorRelay(value: .init(type: .image, image: image)))
//            newValue.append(BehaviorRelay(value: .init(type: .text, input: "")))
//            newState.dataSource = newValue
//
//            return newState
        }
    }
}
