//
//  UITextField+.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/12/28.
//

import UIKit
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.size.height))
        leftView = paddingView
        leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.size.height))
        rightView = paddingView
        rightViewMode = .always
    }
}
