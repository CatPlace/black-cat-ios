//
//  DropDownTableViewCell.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/23.
//

import UIKit

import SnapKit

final class CategoryListTableViewCell: UITableViewCell {

    static let identifier = String(describing: CategoryListTableViewCell.self)

    // MARK: - Functions

    func configure(with categoryName: String) {
        categoryLabel.text = categoryName
    }

    // MARK: - Initializing

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none

        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIComponents

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true

        return label
    }()
}

extension CategoryListTableViewCell {
    private func setUI() {
        contentView.addSubview(categoryLabel)

        categoryLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.top.bottom.equalToSuperview()
        }
    }
}
