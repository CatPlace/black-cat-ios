//
//  BPMultiCastDelegate.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/31.
//

import Foundation

// 🐻‍❄️ NOTE: - Rx Extension으로 처리할 수 있습니다.

protocol BPMulticastDelegate {
    typealias type = BPContentSectionHeaderView.BPContentHeaderButtonType
    // 🐻‍❄️ NOTE: - 아래 함수들의 네이밍을 변경해야 합니다.
    
    /** to BPContentSectionHeaderView*/ func notifyToContentHeader(indexPath: IndexPath, forType: type)
    /** to notifyToContentCell*/ func notifyToContentCell(indexPath: IndexPath, forType: type)
    /** to notifyToViewController*/ func notifyToViewController(offset: CGFloat)
    /** to notifyToCellCollectionViewOffset*/ func notifyToCellCollectionViewOffset(value: Bool)
}

extension BPMulticastDelegate {
    func notifyToContentHeader(indexPath: IndexPath, forType: type) { }
    func notifyToContentCell(indexPath: IndexPath, forType: type) { }
    func notifyToViewControllerOffset(offset: CGFloat) { }
    func notifyToCellCollectionViewOffset(value: Bool) { }
}

// MARK: - Delegating Object
public class DispatchSystem {
    let multicastDelegate = MulticastDelegate<BPMulticastDelegate>()
}
