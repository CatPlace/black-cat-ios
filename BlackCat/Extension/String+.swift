//
//  String+.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/02/21.
//

import Foundation

extension String {
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        return dateFormatter.date(from: self)
    }
}
