//
//  HomeSection2Cell.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/07.
//

import UIKit

import RxCocoa
import RxSwift
import Nuke
import SnapKit

class HomeAllTattoosCell: UICollectionViewCell {

    // MARK: - Properties

    let disposeBag = DisposeBag()

    // MARK: - Binding

    func bind(to viewModel: HomeAllTattoosCellViewModel) {
        viewModel.imageURLString
            .drive()
            .disposed(by: disposeBag)
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

extension HomeAllTattoosCell {
    private func setUI() {
        contentView.addSubview(thumbnailImageView)

        thumbnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        thumbnailImageView.backgroundColor = .lightGray
    }
}
