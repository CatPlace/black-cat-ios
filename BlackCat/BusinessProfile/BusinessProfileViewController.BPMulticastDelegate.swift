//
//  BusinessProfileViewController.ss.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/31.
//

import UIKit

extension BusinessProfileViewController: BPMulticastDelegate {
    
    func notifyContentCell(indexPath: IndexPath?, forType: type) {
        // 🐻‍❄️ NOTE - section을 rawValue로 참조하게끔 바꾸기 sectionType으로 참조하게끔 추후에 바꾸기
        var indexPath: IndexPath = IndexPath(row: 0, section: 1)
        
        print(" 👉 \(indexPath) : \(forType)")
        switch forType {
        case .profile: indexPath = IndexPath(row: 0, section: 1)
        case .product: indexPath = IndexPath(row: 1, section: 1)
        case .review: indexPath = IndexPath(row: 2, section: 1)
        case .info: indexPath = IndexPath(row: 3, section: 1)
        }
        
        collectionView.scrollToItem(at: indexPath,
                                    at: .top,
                                    animated: true)
    }
    
    func notifyViewController(offset: CGFloat) {
        if offset <= 0 {
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                        at: .top,
                                        animated: true)
        } else {
            UIView.animate(withDuration: 0.3) {
                // 🐻‍❄️ NOTE: - y의 값은 첫번째 섹션의 height과 동일
                self.collectionView.contentOffset = CGPoint(x: 0,
                                                            y: UIScreen.main.bounds.width + 30)
            }
        }
    }
}
