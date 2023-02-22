//
//  CommonFullImageCell.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/25.
//

import UIKit

import RxCocoa
import RxSwift
import Nuke
import SnapKit

class CommonFullImageCellViewModel {
    let imageURLString: String?

    init(imageURLString: String?) {
        self.imageURLString = imageURLString
    }
}

class CommonFullImageCell: UICollectionViewCell {

    // MARK: - Properties

    let disposeBag = DisposeBag()

    // MARK: - Binding

    func bind(to viewModel: CommonFullImageCellViewModel) {
        guard let imageURLString = viewModel.imageURLString else { return }
        if let url = URL(string: imageURLString) {
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

    // MARK: - LifeCycle
    override func prepareForReuse() {
        thumbnailImageView.image = nil
    }
    
    // MARK: - UIComponents

    let thumbnailImageView = UIImageView()
    
}

extension CommonFullImageCell {
    private func setUI() {
        contentView.addSubview(thumbnailImageView)

        thumbnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        thumbnailImageView.backgroundColor = .lightGray
    }
}
