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
    
    var row: Int // 이건 없어도 될 것 같기도 한데 리팩토링 고고
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
