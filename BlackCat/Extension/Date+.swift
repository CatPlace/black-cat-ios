//
//  Date+.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/02/21.
//

import Foundation

extension Date {
    func toSimpleString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
                
        return dateFormatter.string(from: self)
    }
}
