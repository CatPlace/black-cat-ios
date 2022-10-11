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

class HomeTattooAlbumCell: UICollectionViewCell {

    // MARK: - Properties

    let disposeBag = DisposeBag()

    // MARK: - Binding

    func bind(to viewModel: HomeTattooAlbumCellViewModel) {
        if let url = URL(string: viewModel.homeAllTattoos.imageURLString) {
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

extension HomeTattooAlbumCell {
    private func setUI() {
        contentView.addSubview(thumbnailImageView)

        thumbnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        thumbnailImageView.backgroundColor = .lightGray
    }
}
