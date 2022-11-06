//
//  BPPriceInfoEditReactor.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/05.
//

import ReactorKit
import RxRelay

struct BPPriceInfoEditModel {
    enum EditType {
        case text
        case image
    }
    
    var type: EditType
    var input: String
    
    init(type: EditType, input: String) {
        self.type = type
        self.input = input
    }
}

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
        
        var dataSource: BehaviorRelay<[BehaviorRelay<BPPriceInfoEditModel>]>
        
        init(dataSource: BehaviorRelay<[BehaviorRelay<BPPriceInfoEditModel>]>) {
            self.dataSource = dataSource
        }
        
    }
    
    var initialState: State
    var provider: BPPriceInfoEditServiceProtocol
    
    init(provider: BPPriceInfoEditServiceProtocol = BPPriceInfoEditService()) {
        self.provider = provider
        self.initialState = State(dataSource: .init(value: [.init(value: .init(type: .text, input: ""))]))
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
        }
    }
}
