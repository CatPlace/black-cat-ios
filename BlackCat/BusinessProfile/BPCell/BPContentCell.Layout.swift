//
//  BPContentCell.Layout.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import UIKit

extension BPContentCell {
    func setUI() {
        // 🐻‍❄️ NOTE: - Pin + Flex로 추후에 넘어가기
        contentView.addSubview(productCollectionView)
        productCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.addSubview(reivewCollectionView)
        reivewCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection in
            
            // 🐻‍❄️ NOTE: - Int값으로 Section 반환하도록 나중에 리팩토링하기
            switch section {
            case 0: return self.productLayoutSection()
            case 1: return self.reviewLayoutSection()
            default: return self.productLayoutSection()
            }
        }
    }
    
    private func productLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.33),
                                                            heightDimension: .absolute(100)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                         heightDimension: .fractionalWidth(0.33)),
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    private func reviewLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.33),
                                                            heightDimension: .absolute(100)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                         heightDimension: .fractionalWidth(0.33)),
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
}
