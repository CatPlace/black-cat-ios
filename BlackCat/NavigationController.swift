//
//  NavigationController.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/03/08.
//

import UIKit

class NavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
