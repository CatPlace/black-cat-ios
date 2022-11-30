//
//  BMMagazineCell.swift
//  BlackCat
//
//  Created by SeYeong on 2022/11/24.
//

import UIKit

import SnapKit
import RxSwift
import Nuke

class BMMagazineCell: UICollectionViewCell {

    // MARK: - Properties

    let disposeBag = DisposeBag()

    // MARK: - Binding

    func bind(to viewModel: BMTattooCellViewModel) {
        if let url = URL(string: viewModel.imageURLString) {
            Nuke.loadImage(with: url, into: thumbnailImageView)
        }
//        editFilterView.selectNumberLabel.text = viewModel.selectNumberText

        viewModel.showEditView
            .debug("BMMagazineCell EditView isHidden")
            .drive(with: self) { owner, isHidden in
                owner.editFilterView.isHidden = isHidden
            }
            .disposed(by: disposeBag)

        viewModel.selectNumberText
            .debug("이거 뭔데?")
            .drive(with: self) { owner, text in
                owner.editFilterView.selectNumberLabel.text = text
            }
            .disposed(by: disposeBag)
    }

    // function

    // MARK: - Initialize

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    // MARK: - UIComponents

    private let thumbnailImageView = UIImageView()
    private let editFilterView: BMEditFilterView = {
        let view = BMEditFilterView()
        view.isHidden = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()

    private let writerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        return label
    }()
}

extension BMMagazineCell {
    private func setUI() {
        addSubview(thumbnailImageView)

        thumbnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        thumbnailImageView.backgroundColor = .lightGray

        [titleLabel, writerLabel, dateLabel, editFilterView].forEach { contentView.addSubview($0) }

        dateLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(21)
        }

        writerLabel.snp.makeConstraints {
            $0.bottom.equalTo(dateLabel.snp.top)
            $0.leading.equalTo(dateLabel)
        }

        titleLabel.snp.makeConstraints {
            $0.bottom.equalTo(writerLabel.snp.top).offset(-5)
            $0.leading.equalTo(dateLabel)
        }

        editFilterView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
