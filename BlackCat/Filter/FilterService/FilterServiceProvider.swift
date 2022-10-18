//
//  FilterServiceProvider.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/18.
//

import Foundation

protocol FilterServiceProtocol {
    var taskService: FilterTaskServiceProtocol { get set }
    var loactionService: FilterLoactionServiceProtocol { get set }
}

final class FilterServiceProvider: FilterServiceProtocol {
    var taskService: FilterTaskServiceProtocol = FilterTaskService()
    var loactionService: FilterLoactionServiceProtocol = FilterLoactionService()
}
