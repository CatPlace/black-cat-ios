//
//  PageControllable.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/07.
//


import Foundation
import CoreGraphics
import UIKit

protocol PageControllable: AnyObject {
    var numberOfPages: Int { get set }
    var currentPage: Int { get }
    var progress: Double { get set }
    var hidesForSinglePage: Bool { get set }
    var borderWidth: CGFloat { get set }

    func set(progress: Int, animated: Bool)
}
