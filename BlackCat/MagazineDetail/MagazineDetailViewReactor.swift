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
    
    enum MagazineDetailCellType {
        case textCell(String)
    }
    
    enum Action {
        case viewDidLoad
    }
    
    enum Mutation {
        case nonmutating
    }
    
    struct State {
        var sections: [MagazineDetailCellSection]
        
        init(sections: [MagazineDetailCellSection]) {
            self.sections = sections
        }
    }
    
    var initialState: State
    
    init() {
        self.initialState = State(
            sections: MagazineDetailViewReactor.confugurationSections()
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .just(.nonmutating)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .nonmutating:
            return newState
        }
    }
}

extension MagazineDetailViewReactor {
    
    static func confugurationSections() -> [MagazineDetailCellSection] {
        let textCell2 = MagazineDetailSectionFactory.makeTextCell(
            MagazineDetailModel(
                text: "",
                fontSize: 0,
                textColor: .black,
                textAlignment: .left,
                fontWeight: .black,
                imageUrlString: "",
                imageCornerRadius: 0
            )
        )
        
        let textCellSection = MagazineDetailCellSection.textCell([textCell2])
        
        return [textCellSection]
    }
}


