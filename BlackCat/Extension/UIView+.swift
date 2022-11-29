//
//  UIView+.swift
//  BlackCat
//
//  Created by SeYeong on 2022/11/02.
//

import UIKit

extension UIView {
    /// keyWindow와 현재 뷰 간의 Frame 좌표 값을 반환합니다.
    var globalFrame: CGRect? {
        let rootView = UIApplication.shared.keyWindow?.rootViewController?.view
        return self.superview?.convert(self.frame, to: rootView)
    }
}
