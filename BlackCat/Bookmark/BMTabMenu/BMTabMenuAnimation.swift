//
//  KNTabMenuAnimation.swift
//  KidsNoteAssignment
//
//  Created by SeYeong on 2022/11/06.
//

import UIKit

import SnapKit

extension BMTabMenuView {
    /**
     ScrollView의 ContentOffset을 받아 TabMenu 하단에 Shadow를 보여줍니다.

     - Parameter minOffset: shadow가 보여지기 시작하는 시점의 Offset, Default: 0
     - Parameter currentOffset: 현재 사용자가 스크롤 중인 Offset
     - Parameter maxOffset: shadow가 더 이상 진해지지 않고, 지속되는 시점의 Offset
     - Parameter shadowRadius: shadow Radius

     */
    func presentShadowWhileScrolling(
        startAt minOffset: CGFloat = 0,
        currentOffset: CGFloat,
        endAt maxOffset: CGFloat,
        shadowRadius: CGFloat = 2.0
    ) {
        guard minOffset < maxOffset,
              currentOffset < maxOffset else { return }

        var currentOffset = currentOffset

        if currentOffset < minOffset { currentOffset = 0.0 }

        let shadowOpacity: Float = currentOffset == 0
        ? 0.0
        : Float((currentOffset / maxOffset)) * 0.3

        let shadowOffset = currentOffset == 0
        ? 0.0
        : ((currentOffset / maxOffset) * (shadowRadius * 2)) + (shadowRadius * 2)

        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: shadowOffset)
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
}


