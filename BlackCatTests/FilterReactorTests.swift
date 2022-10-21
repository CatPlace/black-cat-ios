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

    func test_reactor() {
        // Given
        let reactor = FilterReactor()
        
        // WHen
        reactor.action.onNext(.refresh)
        
        // Then
        let mementoTasks = reactor.provider.taskService.createMemento()
        let mementoLocations = reactor.provider.locationService.createMemento()
        
        do {
            if
                let tasks = try reactor.provider.taskService.fetch().toBlocking().first(),
                let locations = try reactor.provider.locationService.fetch().toBlocking().first()
            {
                expect(tasks.count).to(equal(mementoTasks.count))
                expect(locations.count).to(equal(mementoLocations.count))
                
                let 구독한Tasks = Set(tasks.filter { $0.isSubscribe }.map { $0.type })
                let 구독한MementoTasks = Set(mementoTasks.filter { $0.isSubscribe }.map { $0.type })
                let 구독하지않은Tasks = Set(tasks.filter { !$0.isSubscribe }.map { $0.type })
                let 구독하지않은MementoTasks = Set(mementoTasks.filter { !$0.isSubscribe }.map { $0.type })
                
                expect(구독한Tasks).to(equal(구독한MementoTasks))
                expect(구독하지않은Tasks).to(equal(구독하지않은MementoTasks))
                
                let 구독한Locations = Set(locations.filter { $0.isSubscribe }.map { $0.type })
                let 구독한MementoLocations = Set(mementoLocations.filter { $0.isSubscribe }.map { $0.type })
                let 구독하지않은Locations = Set(locations.filter { !$0.isSubscribe }.map { $0.type })
                let 구독하지않은MementoLocations = Set(mementoLocations.filter { !$0.isSubscribe }.map { $0.type })
                
                expect(구독한Tasks).to(equal(구독한MementoTasks))
                expect(구독하지않은Tasks).to(equal(구독하지않은MementoTasks))
                
            } else {
                XCTFail("🚨 빈배열이에요. 초기저장로직 및 Realm 마이그레이션을 체크해주세요.")
            }
        } catch {
            XCTFail("🚨 Realm에서 읽어오는 것을 실패했습니다.")
        }
    }
}
