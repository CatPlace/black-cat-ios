//
//  UIPageViewController+.swift
//  BlackCat
//
//  Created by SeYeong on 2022/11/10.
//

import UIKit

extension UIPageViewController {
    var scrollView: UIScrollView? {
        for subview in view.subviews {
            if let scrollView = subview as? UIScrollView {
                return scrollView
            }
        }
        return nil
    }
}
