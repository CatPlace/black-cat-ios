//
//  BPPriceInfoEditReactor.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/15.
//

import Foundation
import ReactorKit

final class BPPriceInfoEditReactor: Reactor {
    enum Action {
        case viewDidLoad
        case didTapConfirm
        case didTapClose
        case inputText(String)
    }
    
    enum Mutation {
        case loadText(String) // 서버에 텍스트 값을 요청
        case isDismiss
        case update(String) // input으로 들어오는 텍스트뷰의 값을 처리
    }
    
    struct State {
        @Pulse var text: String = ""
        @Pulse var isDismiss: Bool = false
    }
    
    var initialState: State
    
    init(initialState: State) {
        self.initialState = initialState
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            // TODO: - 서버에서 데이터 받아와서 처리
            return .just(.loadText(""))
        case .didTapConfirm:
            // TODO: - 서버에 send하기
            let text = currentState.text
            
            return .just(.isDismiss)
        case .didTapClose:
            return .just(.isDismiss)
        case .inputText(let text):
            return .just(.update(text))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadText(let text):
            newState.text = text
            
            return newState
        case .isDismiss:
            newState.isDismiss = true
            return newState
        case .update(let text):
            newState.text = text
            return newState
        }
    }
}
