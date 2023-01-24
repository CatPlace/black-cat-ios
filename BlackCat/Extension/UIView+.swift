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
    
    func addBorderGradient(startColor: UIColor, endColor: UIColor, lineWidth: CGFloat, startPoint: CGPoint, endPoint: CGPoint) {
        layer.cornerRadius = bounds.size.height / 2.0
        clipsToBounds = true
        
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        
        
        let shape = CAShapeLayer()
        shape.lineWidth = lineWidth
        shape.path = UIBezierPath(
            arcCenter: CGPoint(x: bounds.height / 2,
                               y: bounds.height / 2),
            radius: bounds.height / 2,
            startAngle: CGFloat(0),
            endAngle:CGFloat(CGFloat.pi * 2),
            clockwise: true).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        layer.addSublayer(gradient)

    }
}
