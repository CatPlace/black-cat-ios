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
//    var viewModel: BMTattooCellViewModel? {
//        didSet {
//            setUI()
//            bind(to: viewModel ?? .init(imageURLString: "B"))
//        }
//    }
    // MARK: - Binding

    func bind(to viewModel: BMTattooCellViewModel) {
        if let url = URL(string: viewModel.imageURLString) {
            Nuke.loadImage(with: url, into: thumbnailImageView)
        }
        editFilterView.selectNumberLabel.text = viewModel.selectNumber
        print("viewModelIMageURLS: \(viewModel.imageURLString)")

        viewModel.showEditView
            .debug("ff")
            .drive(with: self) { owner, isHidden in
                owner.editFilterView.isHidden = isHidden
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Function

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
