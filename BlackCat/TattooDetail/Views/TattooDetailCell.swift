//
//  TattooDetailCell.swift
//  BlackCat
//
//  Created by SeYeong on 2022/12/27.
//

import UIKit

import SnapKit
import Nuke

final class TattooDetailCell: UICollectionViewCell {

    func configure(with imageURLString: String?) {
        if let imageURLString,
           let url = URL(string: imageURLString) {
            Nuke.loadImage(with: url, into: thumbnailImageView)
        } else {
            thumbnailImageView.backgroundColor = .lightGray
        }
    }

    // MARK: - Initialize

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIComponents

    private let thumbnailImageView = UIImageView()
}

extension TattooDetailCell {
    private func setUI() {
        contentView.addSubview(thumbnailImageView)

        thumbnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
