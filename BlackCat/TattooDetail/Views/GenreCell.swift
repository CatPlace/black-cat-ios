//
//  GenreCell.swift
//  BlackCat
//
//  Created by SeYeong on 2023/02/14.
//

import UIKit

import SnapKit
import VisualEffectView
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
        $0.font = .appleSDGoithcFont(size: 14, style: .bold)
        return $0
    }(UILabel())
    
    let blurEffectView: VisualEffectView = {
        let v = VisualEffectView()
        v.colorTintAlpha = 1
        v.backgroundColor = .white.withAlphaComponent(0.4)
        v.blurRadius = 5
        return v
    }()
}

extension GenreCell {
    private func setUI() {
        layer.cornerRadius = 14

        contentView.layer.cornerRadius = 14
        contentView.clipsToBounds = true
        
        contentView.addSubview(blurEffectView)
        contentView.addSubview(genreLabel)

        blurEffectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        genreLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
