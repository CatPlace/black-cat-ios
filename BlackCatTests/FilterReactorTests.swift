//
//  FilterReactorTests.swift
//  FilterReactorTests
//
//  Created by Hamlit Jason on 2022/10/19.
//

import XCTest
@testable import BlackCat

import Nimble
import RxSwift
import RxTest
import RxBlocking

final class FilterReactorTests: XCTestCase {
    
    func test_refresh() {
        // Given
        let reactor = FilterReactor()
        
        // When
        reactor.action.onNext(.refresh)
            
        // Then
        let mementoTasks = reactor.currentState.mementoTasks
        
        let tasks = reactor.currentState.tasks
        
        zip(tasks, mementoTasks).forEach { task, mementoTask in
            XCTAssertEqual(task.isSubscribe, mementoTask.isSubscribe)
            XCTAssertEqual(task.type, mementoTask.type)
        }
    }
    
    
    
}
