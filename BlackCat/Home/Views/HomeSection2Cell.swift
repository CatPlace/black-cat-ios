//
//  HomeSection2Cell.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/07.
//

import UIKit

import Nuke
import SnapKit

class HomeSection2Cell: UICollectionViewCell {

    // MARK: - Properties

    static let identifer = String(describing: HomeSection2Cell.self)

    // MARK: - Binding

    func bind(to viewModel: HomeSection2CellViewModel) {
        if let url = URL(string: viewModel.imageURLString) {
            Nuke.loadImage(with: url, into: thumbnailImageView)
        }
    }


    // MARK: - Initializing

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIComponents

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
