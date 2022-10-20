//
//  FilterReactorTests.swift
//  FilterReactorTests
//
//  Created by Hamlit Jason on 2022/10/19.
//

import XCTest
@testable import BlackCat

import Quick
import Nimble
import RxSwift
import RxTest
import RxBlocking

final class FilterViewControllerTests: QuickSpec {
    
    var sut: FilterReactor?
    
    override func setUp() {
        super.setUp()
        
        sut = FilterReactor()
    }
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
    }

    
    func test_action_refresh() {
        // Given
        let reactor = FilterReactor()
        
        // When
        reactor.action.onNext(.refresh)
        
        // Then
        let mementoTasks = reactor.provider.taskService.createMemento()
        do {
            if let tasks = try reactor.provider.taskService.fetch()
                .toBlocking().toArray().first {
                
                expect(tasks.count).to(equal(mementoTasks.count))
                
                let 구독한Tasks = Set(tasks.filter { $0.isSubscribe }.map { $0.type })
                let 구독한MementoTasks = Set(tasks.filter { $0.isSubscribe }.map { $0.type })
                expect(구독한Tasks).to(equal(구독한MementoTasks))
                
            } else {
                XCTFail("빈배열")
            }
                
        } catch {
            XCTFail("트라이 실패")
        }
    }
}
