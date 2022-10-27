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
        case didTapTaskCell(FilterTask)
        case didTapLocationCell(FilterLocation)
        case didTapApplyTextLabel
        case dismiss
    }
    
    enum Mutation {
        case setTasks([FilterTask])
        case setLocations([FilterLocation])
        
        case isDissmiss
        case isRecoverState
    }
    
    struct State {
        var tasks: [FilterTask] = []
        var locations: [FilterLocation] = []
        
        var isDismiss: Bool = false
        var isRecover: Bool = true
        
        var mementoTasks: [MementoFilterTask] = []
        var mementoLocations: [MementoFilterLocation] = []
        
        init(mementoTasks: [MementoFilterTask], mementoLocations: [MementoFilterLocation]) {
            self.mementoTasks = mementoTasks
            self.mementoLocations = mementoLocations
        }
    }
    
    var initialState: State
    var provider: FilterServiceProtocol
    
    init(provider: FilterServiceProtocol = FilterServiceProvider()) {
        self.initialState = State(mementoTasks: provider.taskService.createMemento(),
                                  mementoLocations: provider.locationService.createMemento())
        self.provider = provider
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            return .concat([
                provider.taskService.fetch().map { .setTasks($0) },
                provider.locationService.fetch().map { .setLocations($0) }
            ])
                
        case .didTapTaskCell(let task):
            return provider.taskService.update(task: task)
                .map { tasks in
                    return .setTasks(tasks)
                }
            
        case .didTapLocationCell(let location):
            return provider.locationService.update(location: location)
                .map { locations in
                    return .setLocations(locations)
                }
            
        case .dismiss:
            return .just(.isDissmiss)
            
        case .didTapApplyTextLabel:
            return .concat([
                .just(.isRecoverState),
                .just(.isDissmiss)
            ])
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
        case .isDissmiss:
            self.recover(isRecover: currentState.isRecover)
            newState.isDismiss = true
            return newState
        case .isRecoverState:
            newState.isRecover = false
            return newState
        }
    }
}

extension FilterReactor {
    func recover(isRecover: Bool) {
        if isRecover {
            provider.taskService.recoverLastState(tasks: currentState.tasks,
                                               mementoTasks: currentState.mementoTasks)
            
            provider.locationService.recoverLastState(locations: currentState.locations,
                                                   mementoLocations: currentState.mementoLocations)
        }
    }
}
