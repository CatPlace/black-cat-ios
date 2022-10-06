//
//  PageControlLayer.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/07.
//

import QuartzCore

class PageControlLayer: CAShapeLayer {


    override init() {
        super.init()
        self.actions = [
            "bounds": NSNull(),
            "frame": NSNull(),
            "position": NSNull()
        ]
    }
    
    override public init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
