//
//  HomeCategoryCell.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/05.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

class HomeCategoryCell: UICollectionViewCell {

    // MARK: - Properties

    static let identifier = String(describing: HomeCategoryCell.self)
    let disposeBag = DisposeBag()

    // MARK: - Binding

    func bind(to viewModel: HomeCategoryCellViewModel) {
//        categoryTitleLabel.text = viewModel.title
    }

    // MARK: - Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIComponents

    let categoryTitleLabel = UILabel()
}

extension HomeCategoryCell {
    func setUI() {
        layer.cornerRadius = 12
        layer.masksToBounds = true

        contentView.addSubview(categoryTitleLabel)
        contentView.backgroundColor = .white

        categoryTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(9)
            $0.trailing.equalToSuperview().inset(9)
            $0.centerX.centerY.equalToSuperview()
        }

        categoryTitleLabel.textAlignment = .center
        categoryTitleLabel.numberOfLines = 0
        categoryTitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
    }
}
