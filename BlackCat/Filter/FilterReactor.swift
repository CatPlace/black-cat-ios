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
        case setTasks([FilterTask])
        case updateTask(FilterTask)
    }
    
    struct State {
        @Pulse var tasks: [FilterTask] = []
    }
    
    var initialState: State
    var provider: FilterServiceProtocol
    
    init(provider: FilterServiceProtocol = FilterServiceProvider()) {
        self.provider = provider
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            return provider.taskService.fetch()
                .map { tasks in
                    return .setTasks(tasks)
                }
                
        case .didTapCell(let task):
            return .just(.updateTask(task))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setTasks(tasks):
            newState.tasks = tasks
            return newState
        case .updateTask(let task):
            FilterTask().update(task: task)
            return newState
        }
    }
}


