//
//  BPContentSectionHeaderReactor.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/31.
//

import ReactorKit

final class BPContentSectionHeaderReactor: Reactor {
    typealias CafeHeaderButtonType = CafeSectionHeaderView.CafeHeaderButtonType
    
    enum Action {
        case didTapButton1
        case didTapButton2
        case didTapButton3
        case didTapButton4
    }
    
    enum Mutation {
        case selectedButton(CafeHeaderButtonType) // 선택된 버튼들
        // 컬렉션 뷰 페이지 변경
    }

    struct State {
        @Pulse var selectedButton: CafeHeaderButtonType
        
        init(selectedButton: CafeHeaderButtonType = .button1) {
            self.selectedButton = .button1
        }
    }
    
    var initialState: State
    
    init(initialState: State) {
        self.initialState = initialState
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTapButton1:
            return .just(.selectedButton(.button1))
        case .didTapButton2:
            return .just(.selectedButton(.button2))
        case .didTapButton3:
            return .just(.selectedButton(.button3))
        case .didTapButton4:
            return .just(.selectedButton(.button4))
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
