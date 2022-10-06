//
//  MagazineDetailTextCellReactor.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/06.
//

import Foundation
import ReactorKit

final class MagazineDetailTextCellReactor: Reactor {

    typealias Action = NoAction

    var initialState: MagazineDetailModel

    init(initialState: MagazineDetailModel) {
        self.initialState = initialState
    }
}
