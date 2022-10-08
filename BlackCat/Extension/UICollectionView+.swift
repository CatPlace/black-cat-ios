//
//  UICollectionView+.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/09.
//

import UIKit

extension UICollectionView {
    func register<T: UICollectionViewCell>(_ cell: T.Type) {
        let identifier: String = String(describing: T.self)
        self.register(T.self, forCellWithReuseIdentifier: identifier)
    }
    func dequeueReusableCell<T: UICollectionViewCell>(_ cell: T.Type, for indexPath: IndexPath) -> T {
        let identifier: String = String(describing: T.self)
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T else {
            return .init()
        }
        return cell
    }
}

