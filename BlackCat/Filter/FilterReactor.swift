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
        case setLocations([FilterLocation])
    }
    
    struct State {
        var tasks: [FilterTask] = []
        var locations: [FilterLocation] = []
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
            return .concat([
                provider.taskService.fetch()
                    .map { tasks in
                        return .setTasks(tasks)
                    },
                provider.loactionService.fetch()
                    .map { locations in
                        return .setLocations(locations)
                    }
            ])
            
                
        case .didTapCell(let task):
            return provider.taskService.update(task: task)
                .map { tasks in
                    return .setTasks(tasks)
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setTasks(tasks):
            newState.tasks = tasks
            return newState
        case let .setLocations(locations):
            newState.locations = locations
            return newState
        }
    }
}


