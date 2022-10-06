//
//  MagazineDetailViewReactor.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/06.
//

import UIKit
import ReactorKit
import RxSwift

final class MagazineDetailViewReactor: Reactor {
    enum Action { }
    enum Mutation { }
    struct State { }
    
    var initialState: State
    
    init(initialState: State) {
        self.initialState = initialState
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        //
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        //
    }
}
