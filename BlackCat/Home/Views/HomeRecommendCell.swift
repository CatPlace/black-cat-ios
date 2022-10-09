//
//  HomeSection1Cell.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/06.
//

import UIKit

import Nuke
import SnapKit

class HomeRecommendCell: UICollectionViewCell {

    // MARK: - Binding

    func bind(to viewModel: HomeRecommendCellViewModel) {

        // TODO: - Nuke 조사 필요합니다..

        if let url = URL(string: viewModel.homeRecommend.imageURLString) {
            Nuke.loadImage(with: url, into: thumbnailImageView)
        }
        priceLabel.text = viewModel.homeRecommend.priceString
        tattooistNameLabel.text = viewModel.homeRecommend.tattooistName
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
    let priceLabel = UILabel()
    let tattooistNameLabel = UILabel()
}

extension HomeRecommendCell {
    func setUI() {
        [thumbnailImageView, priceLabel, tattooistNameLabel].forEach { contentView.addSubview($0) }

        thumbnailImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.equalTo(140)
            $0.height.equalTo(140)
        }
        thumbnailImageView.backgroundColor = .gray

        priceLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(thumbnailImageView.snp.bottom).offset(10)
        }

        priceLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)

        tattooistNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(priceLabel.snp.bottom).offset(2)
        }

        tattooistNameLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
    }
}
