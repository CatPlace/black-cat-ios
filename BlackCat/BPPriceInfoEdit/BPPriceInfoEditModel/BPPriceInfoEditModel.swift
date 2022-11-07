//
//  BPPriceInfoEditModel.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/07.
//

import Foundation

struct BPPriceInfoEditModel {
    enum EditType {
        case text
        case image
    }
    
    var row: Int
    var type: EditType
    var input: String
    
    init(row: Int, type: EditType, input: String) {
        self.row = row
        self.type = type
        self.input = input
    }
}
