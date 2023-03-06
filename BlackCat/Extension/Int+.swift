//
//  Int+.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/03/07.
//

import Foundation
extension Int {
    func numberStringWithComma() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}
