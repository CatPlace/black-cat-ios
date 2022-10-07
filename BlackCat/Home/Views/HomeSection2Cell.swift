//
//  HomeSection2Cell.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/07.
//

import UIKit

import SnapKit

class HomeSection2Cell: UICollectionViewCell {

    static let identifer = String(describing: HomeSection2Cell.self)

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let thumbnailImageView = UIImageView()
}

extension HomeSection2Cell {
    private func setUI() {
        contentView.addSubview(thumbnailImageView)

        thumbnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        thumbnailImageView.backgroundColor = .lightGray
    }
}
