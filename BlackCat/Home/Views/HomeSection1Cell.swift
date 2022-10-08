//
//  HomeSection1Cell.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/06.
//

import UIKit

import Nuke
import SnapKit

class HomeSection1Cell: UICollectionViewCell {

    // MARK: - Properties

    static let identifier = String(describing: HomeSection1Cell.self)

    // MARK: - Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(to viewModel: HomeSection1CellViewModel) {

        // TODO: - Nuke 조사 필요합니다..

        Nuke.loadImage(with: URL(string: viewModel.imageURLString)!, into: thumbnailImageView)
        priceLabel.text = viewModel.price
        producerLabel.text = viewModel.producerName
    }

    // MARK: - UIComponents

    let thumbnailImageView = UIImageView()
    let priceLabel = UILabel()
    let producerLabel = UILabel()
}

extension HomeSection1Cell {
    func setUI() {
        [thumbnailImageView, priceLabel, producerLabel].forEach { contentView.addSubview($0) }

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

        priceLabel.text = "19500원"
        priceLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)

        producerLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(priceLabel.snp.bottom).offset(2)
//            $0.bottom.equalToSuperview()
        }

        producerLabel.text = "김타투"
        producerLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
    }
}
