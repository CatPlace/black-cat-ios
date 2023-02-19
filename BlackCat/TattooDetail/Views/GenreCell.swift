//
//  GenreCell.swift
//  BlackCat
//
//  Created by SeYeong on 2023/02/14.
//

import UIKit

import SnapKit

final class GenreCell: UICollectionViewCell {

    func configure(with title: String) {
        genreLabel.text = title
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

    private let genreLabel: UILabel = {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 14, weight: .bold)
        return $0
    }(UILabel())
}

extension GenreCell {
    private func setUI() {
        layer.cornerRadius = 14

        contentView.layer.cornerRadius = 14
        contentView.backgroundColor = .lightGray.withAlphaComponent(0.3)

        contentView.addSubview(genreLabel)

        genreLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
