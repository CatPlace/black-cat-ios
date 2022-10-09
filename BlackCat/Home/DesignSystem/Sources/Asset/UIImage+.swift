//
//  UIImage_.swift
//  catplace
//
//  Created by SeYeong on 2022/09/29.
//

import UIKit

public extension UIImage {
    convenience init?(_ asset: Asset) {
        self.init(named: asset.rawValue)
    }
}
