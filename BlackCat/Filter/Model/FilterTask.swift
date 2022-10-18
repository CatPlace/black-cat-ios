//
//  Task.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/16.
//

import Foundation

// NOTE: - GOTO SDK 🥕
public class FilterTask: Codable {
    
    public enum TaskType: String, CaseIterable, Codable {
        case 작품
        case 도안
    }
    
    public var type: TaskType = .작품
    public var isSubscribe: Bool = false
    
    init(type: TaskType, isSubscribe: Bool) {
        self.type = type
        self.isSubscribe = isSubscribe
    }
}
