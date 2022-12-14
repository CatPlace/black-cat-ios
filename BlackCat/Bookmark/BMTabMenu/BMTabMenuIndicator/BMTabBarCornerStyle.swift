//
//  KNTabCornerStyle.swift
//  KidsNoteAssignment
//
//  Created by SeYeong on 2022/11/06.
//

import Foundation

enum CornerStyle {
    case square
    case eliptical
}

extension CornerStyle {
    func cornerRadius(in frame: CGRect) -> CGFloat {
        switch self {
        case .square: return 0.0
        case .eliptical: return frame.height / 2.0
        }
    }
}
