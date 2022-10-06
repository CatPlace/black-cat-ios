//
//  MagazineFamousItemCell.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/07.
//

import UIKit

import Nuke

struct MagazineFamousItemCellViewModel {
    let imageUrl: String
}

class MagazineFamousItemCell: UICollectionViewCell {
    // MARK: - Properties
    var viewModel: MagazineFamousItemCellViewModel? {
        didSet {
            setImage()
            setUI()
        }
    }

    // MARK: - UIComponents
    let famouseMagazineImageView = UIImageView()
}

extension MagazineFamousItemCell {
    
    func setImage() {
        guard let viewModel, let url = URL(string: viewModel.imageUrl) else { return }
        let request = ImageRequest(url: url,priority: .high)
        Nuke.loadImage(with: request, into: famouseMagazineImageView)
    }
    
    func setUI() {
        contentView.addSubview(famouseMagazineImageView)
        
        famouseMagazineImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}
