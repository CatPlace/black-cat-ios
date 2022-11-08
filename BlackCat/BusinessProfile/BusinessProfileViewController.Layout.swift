//
//  BPViewController.CollectionLayout.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import UIKit
import SnapKit

extension BusinessProfileViewController {
    func setUI() {
        self.navigationController?.navigationBar.isHidden = true
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection in
            
            // 🐻‍❄️ NOTE: - section을 Int값이 아니라 BPSection타입으로 변경하기
            switch section {
            case 0: return self.thumbnailLayoutSection()
            case 1: return self.contentLayoutSection()
            default: return self.contentLayoutSection()
            }
        }
    }
    
    private func thumbnailLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .fractionalWidth(1.0)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                         heightDimension: .fractionalWidth(1)),
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    private func contentLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .fractionalHeight(1.0)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                         heightDimension: .fractionalHeight(1.0)),
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                              heightDimension: .absolute(30)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        header.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [header]
        
        return section
    }
}
