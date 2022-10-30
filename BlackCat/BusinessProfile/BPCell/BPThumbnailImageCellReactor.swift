//
//  BPThumnailImageCellReactor.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import ReactorKit

final class BPThumbnailImageCellReactor: Reactor {
    typealias Action = NoAction

    var initialState: BPThumbnailModel

    init(initialState: BPThumbnailModel) {
        self.initialState = initialState
    }
}
