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
        
        contentView.addSubview(profileCollectionView)
        profileCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.addSubview(productCollectionView)
        productCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.addSubview(reviewCollectionView)
        reviewCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.addSubview(priceInfoCollectionView)
        priceInfoCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func createLayout(forType type: BPContentType) -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection in
            
            // 🐻‍❄️ NOTE: - Int값으로 Section 반환하도록 나중에 리팩토링하기
            switch type {
            case .profile: return self.profileLayoutSection()
            case .product: return self.productLayoutSection()
            case .review: return self.reviewLayoutSection()
            case .priceInfo: return self.priceInfoLayoutSection()
            default: assert(false, "🚨\(#function) error 발생")
            }
        }
    }
    
    private func profileLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .estimated(100)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                         heightDimension: .estimated(100)),
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    private func productLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1/3),
                                                            heightDimension: .fractionalWidth(1/3)))
        item.contentInsets = .init(top: 2, leading: 1, bottom: 2, trailing: 1)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                         heightDimension: .fractionalWidth(0.33)),
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    private func reviewLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = .init(top: 6, leading: 20, bottom: 6, trailing: 20)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                         heightDimension: .absolute(112)),
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    private func priceInfoLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .estimated(100)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                         heightDimension: .estimated(100)),
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
}
