//
//  UIImage+.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/08.
//

import UIKit

extension UIImage {
    convenience init?(_ asset: Asset) {
        self.init(named: asset.rawValue, in: Bundle.main, with: nil)
    }

    convenience init?(assetName: String) {
        self.init(named: assetName, in: Bundle.main, with: nil)
    }
}
