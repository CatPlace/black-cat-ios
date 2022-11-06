//
//  BPPriceInfoEditReactor.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/05.
//

import UIKit
import ReactorKit
import RxRelay

final class BPPriceInfoEditReactor: Reactor {
    enum Action {
        case didTapCloseItem
        case didTapPhotoItem
        case didTapConfirmItem(String)
        case appendImage(UIImage)
    }
    
    enum Mutation {
        case isDismiss
        case openPhotoLibrary
        case sendProfile(String)
        case appendImage(UIImage)
    }
    
    struct State {
        var isDismiss = false
        @Pulse var isOpenPhotoLibrary = false
        
        var dataSource: BehaviorRelay<[BPPriceInfoEditModel]>
        
        init(dataSource: BehaviorRelay<[BPPriceInfoEditModel]>) {
            self.dataSource = dataSource
        }
        
    }
    
    var initialState: State
    var provider: BPPriceInfoEditServiceProtocol
    
    init(provider: BPPriceInfoEditServiceProtocol = BPPriceInfoEditService()) {
        self.provider = provider
        self.initialState = State(dataSource: .init(value: [.init(type: .text, input: "안녕하세요.")]))
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
        case .appendImage(let image):
            return .just(.appendImage(image))
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
        case .appendImage(let image):
            var newValue = currentState.dataSource.value
            newValue.append(.init(type: .image, image: image))
            newValue.append(.init(type: .text, input: ""))
            newState.dataSource.accept(newValue)
            
            return newState
        }
    }
}
