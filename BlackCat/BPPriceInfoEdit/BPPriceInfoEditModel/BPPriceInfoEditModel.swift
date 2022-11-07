//
//  BPPriceInfoEditModel.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/07.
//

import UIKit

struct BPPriceInfoEditModel {
    enum EditType {
        case text
        case image
    }
    
    var row: Int
    var type: EditType
    var input: String = ""
    var image: UIImage
    
    init(row: Int, type: EditType, input: String = "", image: UIImage = UIImage()) {
        self.row = row
        self.type = type
        self.input = input
        self.image = image
    }
}
