//
//  FilterViewModel.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/16.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import ReactorKit

final class FilterReactor: Reactor {
    
    enum Action {
        case refresh
        case didTapCell(FilterTask)
    }
    
    enum Mutation {
        case setTasks
        case updateTask(FilterTask)
    }
    
    struct State {
        var tasks: [FilterTask] = FilterTask().fetch()
    }
    
    var initialState: State
    
    init() {
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            return .just(.setTasks)
        case .didTapCell(let task):
            return .just(.updateTask(task))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setTasks: return newState
        case .updateTask(let task):
            FilterTask().write(
                task: FilterTask(
                    type: task.type,
                    isSubscribe: !task.isSubscribe
                )
            )
//            newState.tasks =
            return newState
        }
    }
}
