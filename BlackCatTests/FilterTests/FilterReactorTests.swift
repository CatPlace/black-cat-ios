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
    func test_CI_테스트용() {
        XCTAssertTrue(true)
        XCTAssertEqual(0, 0)
    }
    
    // MARK: - Reactor를 테스트합니다.
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
        
        let mementoLocations = reactor.currentState.mementoLocations
        let locations = reactor.currentState.locations
        
        zip(locations, mementoLocations).forEach { location, mementoLocation in
            expect(location.type).to(equal(mementoLocation.type))
            expect(location.isSubscribe).to(equal(mementoLocation.isSubscribe))
        }
    }
    
    func test_didTapTaskCell() {
        // Given
        let reactor = FilterReactor()
        let mock = FilterTask(type: .도안, isSubscribe: false)
        
        // When
        reactor.action.onNext(.didTapTaskCell(mock))
        
        // Then
        expect(mock.isSubscribe) == true
    }
    
    func test_didTapLocationCell() {
        // Given
        let reactor = FilterReactor()
        let mock = FilterLocation(type: .경남_부산_울산, isSubscribe: false)
        
        // When
        reactor.action.onNext(.didTapLocationCell(mock))
        
        // Then
        expect(mock.isSubscribe) == true
    }
    
    func test_didTapApplyTextLabel() {
        // Given
        let reactor = FilterReactor()
        
        // When
        reactor.action.onNext(.didTapApplyTextLabel)
        
        // Then
        expect(reactor.currentState.isRecover) == false
        expect(reactor.currentState.isDismiss) == true
    }
    
    func test_dismiss() {
        // Given
        let reactor = FilterReactor()
        
        // When
        reactor.action.onNext(.dismiss)
        
        // Then
        expect(reactor.currentState.isRecover) == true
        expect(reactor.currentState.isDismiss) == true
    }
}
