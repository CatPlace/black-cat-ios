//
//  MyPageViewController.Layout.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/23.
//

import UIKit
import BlackCatSDK

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
        let itemWidthRatio: CGFloat = 335 / 375
        let itemHeightRatio: CGFloat = (CatSDKUser.userType() == .business ? 131 : 82) / 335
        
        let itemLeadingTrailingInset: CGFloat = view.frame.width * (1 - itemWidthRatio) / 2.0
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(itemHeightRatio)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(itemHeightRatio)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        section.contentInsets = .init(top: 30,
                                      leading: itemLeadingTrailingInset,
                                      bottom: 40,
                                      trailing: itemLeadingTrailingInset)
        
        return section
    }
    
    func recentTattooSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(217 / 375.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(160 / 375.0),
            heightDimension: .fractionalWidth(217 / 375.0)
        )
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                       subitem: item,
                                                       count: 1)
        group.contentInsets = .init(top: 0, leading: 6, bottom: 0, trailing: 6)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(38)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        

        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    func menuSection() -> NSCollectionLayoutSection {
        let itemWidthRatio: CGFloat = 335 / 375
        let itemHeightRatio: CGFloat = 50 / 335
        let itemLeadingTrailingInset: CGFloat = view.frame.width * (1 - itemWidthRatio) / 2.0
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(itemHeightRatio)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(itemHeightRatio)
        )
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 15
        section.orthogonalScrollingBehavior = .none
        section.contentInsets = .init(top: 40,
                                      leading: itemLeadingTrailingInset,
                                      bottom: 40,
                                      trailing: itemLeadingTrailingInset)
        return section
    }
}

