//
//  HomeHeaderView.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/07.
//

import UIKit

import SnapKit

class HomeHeaderView: UICollectionReusableView {

    static let identifer = String(describing: self)

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let titleLabel = UILabel()
}

extension HomeHeaderView {
    private func setUI() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.top.equalToSuperview().inset(15)
        }

        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
    }
}
