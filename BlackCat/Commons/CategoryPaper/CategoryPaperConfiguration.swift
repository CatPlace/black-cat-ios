//
//  DropDownConfiguration.swift
//  BlackCat
//
//  Created by SeYeong on 2022/11/02.
//

import UIKit

class CategoryPaperConfiguration {
    private let presentationView = PresentationView()
    lazy var tableView = presentationView.tableView
    lazy var backgroundView = presentationView.backgroundView
    lazy var menuWrapper = presentationView.menuWrapper

    var presentationStyle: PresentationStyle

    var cellHeight: CGFloat {
        get {
            tableView.rowHeight
        } set {
            tableView.rowHeight = newValue
        }
    }

    var backgroundColor: UIColor? {
        get {
            tableView.backgroundColor
        } set {
            tableView.backgroundColor = newValue
        }
    }

    var animateDuration: TimeInterval!

    var dropDownCellInset: UIEdgeInsets {
        get {
            tableView.contentInset
        } set {
            tableView.contentInset = newValue
        }
    }

    var width: CGFloat!

    var arrowImage: UIImage?

    init() {
        self.presentationStyle = .dropDown
        self.cellHeight = 28
        self.backgroundColor = .white
        self.animateDuration = 0.35
        self.dropDownCellInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        self.width = 130
        self.arrowImage = UIImage(named: "arrowtriangle.down.fill")
    }
}
