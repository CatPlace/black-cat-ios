//
//  BusinessProfileReactor.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import ReactorKit

final class BusinessProfileReactor: Reactor {
    enum Action {
        case viewDidLoad
    }
    
    enum Mutation {
        case fetchSection
    }
    
    struct State {
        var sections: [BusinessProfileCellSection]
        
        init(sections: [BusinessProfileCellSection]) {
            self.sections = sections
        }
    }
    
    var initialState: State
    
    init(initialState: State) {
        self.initialState = initialState
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .just(.fetchSection)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .fetchSection:
            newState.sections = []
            return newState
        }
    }
}
