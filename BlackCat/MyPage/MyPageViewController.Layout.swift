//
//  MyPageViewController.Layout.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/23.
//

import UIKit

extension MyPageViewController {
    func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] section, _ -> NSCollectionLayoutSection? in
            
            guard let sectionType = MyPageSectionType(rawValue: section), let self else { return nil }
            switch sectionType {
            case .profile: return self.profileSection()
            case .recentTattoo: return self.recentTattooSection()
            case .menu: return self.menuSection()
            }
        }
    }
    
    func profileSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.6)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.6)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none

        return section
    }
    
    func recentTattooSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(160 / 375.0),
            heightDimension: .fractionalWidth(217 / 375.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(160 / 375.0),
            heightDimension: .fractionalWidth(217 / 375.0)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        return section
    }
    
    func menuSection() -> NSCollectionLayoutSection {
        let itemWidth: CGFloat = 335 / 375
        let itemHeight: CGFloat = 50 / 375
        let itemLeadingTrailingInset: CGFloat = view.frame.width * (1 - itemWidth) / 2.0
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(itemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = .init(top: 0,
                                   leading: itemLeadingTrailingInset,
                                   bottom: 0,
                                   trailing: itemLeadingTrailingInset)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(itemHeight)
        )
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 15
        section.orthogonalScrollingBehavior = .none
        section.contentInsets = .init(top: 0, leading: 0, bottom: 40, trailing: 0)
        return section
    }
}

