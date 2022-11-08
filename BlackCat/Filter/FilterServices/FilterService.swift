//
//  FilterServiceProvider.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/18.
//

import Foundation

protocol FilterServiceProtocol {
    var taskService: FilterTaskServiceProtocol { get set }
    var locationService: FilterLocationServiceProtocol { get set }
}

final class FilterService: FilterServiceProtocol {
    var taskService: FilterTaskServiceProtocol = FilterTaskService()
    var locationService: FilterLocationServiceProtocol = FilterLoactionService()
}
