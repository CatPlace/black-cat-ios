//
//  JHBusinessProfileViewController.Layout.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/02/18.
//

import UIKit

extension JHBusinessProfileViewController {
    func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] section, env -> NSCollectionLayoutSection? in

            // 🐻‍❄️ NOTE: - section을 Int값이 아니라 BPSection타입으로 변경하기
            switch section {
            case 0: return self?.thumbnailLayoutSection()
            case 1: return self?.contentLayoutSection()
            default: return self?.contentLayoutSection()
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
                                                                         heightDimension: .fractionalHeight(0.8)),
                                                       subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging

        section.visibleItemsInvalidationHandler = { [weak self] (items, offset, _) -> Void in
            guard let self else { return }
            let adjustedOffsetX = offset.x / self.view.bounds.width
            if adjustedOffsetX == floor(adjustedOffsetX) {
                self.viewModel.cellDidAppear.accept(adjustedOffsetX)
            }

            let page = round(adjustedOffsetX)

            self.viewModel.cellWillAppear.accept(page)
        }

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                              heightDimension: .absolute(UIScreen.main.bounds.width * 40 / 375)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        header.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [header]

        return section
    }
}
