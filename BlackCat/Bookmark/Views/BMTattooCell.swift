//
//  BMTattooCell.swift
//  BlackCat
//
//  Created by SeYeong on 2022/11/18.
//

import UIKit

import SnapKit
import RxGesture
import RxSwift
import Nuke

class BMTattooCell: UICollectionViewCell {
    // MARK: - Properties

    let disposeBag = DisposeBag()

    // MARK: - Binding

    func bind(to viewModel: BMCellViewModel) {
        if let url = URL(string: viewModel.imageURLString) {
            Nuke.loadImage(with: url, into: thumbnailImageView)
            thumbnailImageView.image = UIImage(named: "DummyPict")
        }

        viewModel.shouldHideEditView
            .drive(with: self) { owner, isHidden in
                owner.editFilterView.isHidden = isHidden
            }
            .disposed(by: disposeBag)

        viewModel.selectNumberText
            .drive(with: self) { owner, text in
                owner.editFilterView.update(with: text)
            }
            .disposed(by: disposeBag)
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

    let thumbnailImageView = UIImageView()
    let editFilterView: BMEditFilterView = {
        let view = BMEditFilterView()
        view.isHidden = true
        return view
    }()
}

extension BMTattooCell {
    private func setUI() {
        contentView.addSubview(thumbnailImageView)

        thumbnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        thumbnailImageView.backgroundColor = .lightGray

        contentView.addSubview(editFilterView)

        editFilterView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
