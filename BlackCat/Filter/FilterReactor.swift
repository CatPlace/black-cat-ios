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
        case isRevert
    }
    
    struct State {
        var tasks: [FilterTask] = []
        var locations: [FilterLocation] = []
        
        var isDismiss: Bool = false
        var isRevert: Bool = true
        
        var revertTasks: [RevertFilterTask] = []
        var revertLocations: [FilterLocation] = []
        
        init(revertTasks: [RevertFilterTask], revertLocations: [FilterLocation]) {
            self.revertTasks = revertTasks
            self.revertLocations = revertLocations
        }
    }
    
    var initialState: State
    var provider: FilterServiceProtocol
    
    init(provider: FilterServiceProtocol = FilterServiceProvider()) {
        self.initialState = State(revertTasks: provider.taskService.fetchRevert(),
                                  revertLocations: provider.locationService.fetchRevert())
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
                .just(.isRevert),
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
            self.revert(isRevert: currentState.isRevert)
            newState.isDismiss = true
            return newState
        case .isRevert:
            newState.isRevert = false
            return newState
        }
    }
}

extension FilterReactor {
    func revert(isRevert: Bool) {
        if isRevert {
            provider.taskService.executeRevert(tasks: currentState.tasks,
                                               revertTasks: currentState.revertTasks)
        }
    }
}
