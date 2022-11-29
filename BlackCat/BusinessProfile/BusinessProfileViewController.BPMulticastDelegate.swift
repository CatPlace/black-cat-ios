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
        
        // 🐻‍❄️ NOTE: - 'offset <= ?' ?를 정해 볼까요?
//        if offset <= UIScreen.main.bounds.height / 3 {
        if offset <= 1 {
            UIView.animate(withDuration: 0.3) {
                self.collectionView.contentOffset = CGPoint(x: 0, y: 0)
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                // 위쪽으로 y만큼 당긴다고 생각하기
                self.collectionView.contentOffset = CGPoint(x: 0, y: 200)
            }
        }
    }
}
