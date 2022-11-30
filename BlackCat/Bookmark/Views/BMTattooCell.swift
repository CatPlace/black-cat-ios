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
        viewModel.selectNumber
            .debug(";;")
            .subscribe { _ in

            }
            .disposed(by: disposeBag)

        if let url = URL(string: viewModel.imageURLString) {
            Nuke.loadImage(with: url, into: thumbnailImageView)
        }
//        editFilterView.selectNumberLabel.text = viewModel.selectNumberText
        print("viewModelIMageURLS: \(viewModel.imageURLString)")

//        print(address(of: viewModel.selectNumber))
        print(address(o: viewModel))

        viewModel.showEditView
            .debug("BMTattooCell ShowEditView")
            .drive(with: self) { owner, isHidden in
                owner.editFilterView.isHidden = isHidden
            }
            .disposed(by: disposeBag)

        viewModel.selectNumberText
            .debug("BMTattooCell SelectNumberText")
            .drive(with: self) { owner, text in
                owner.editFilterView.selectNumberLabel.text = text
            }
            .disposed(by: disposeBag)
    }

    func address(of object: UnsafeRawPointer) -> String {
        let address = Int(bitPattern: object)
        return String(format: "%p", address)
    }

    func address<T: AnyObject>(o: T) -> Int {
        return unsafeBitCast(o, to: Int.self)
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
