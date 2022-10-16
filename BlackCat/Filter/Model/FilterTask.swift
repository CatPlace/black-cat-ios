//
//  Task.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/16.
//

import Foundation

enum FilterTaskType: String, CaseIterable {
    case 작품
    case 도안
}

struct FilterTask {
    var type: FilterTaskType
    var isSubscribe: Bool
    
    init(item: FilterTaskType, isSubscribe: Bool = false) {
        self.type = item
        self.isSubscribe = isSubscribe
    }
}
