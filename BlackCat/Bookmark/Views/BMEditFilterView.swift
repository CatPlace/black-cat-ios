//
//  BMEditFilterView.swift
//  BlackCat
//
//  Created by SeYeong on 2022/11/18.
//

import UIKit

import SnapKit

class BMEditFilterView: UIView {

    // MARK: - Properties

    // MARK: - Binding

    // function

    // MARK: - Initialize

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIComponents

    private let blackFilterView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()

    private let selectNumberCircleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        return view
    }()

    let selectNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .purple
        return label
    }()
}

extension BMEditFilterView {
    private func setUI() {
        addSubview(blackFilterView)

        blackFilterView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        addSubview(selectNumberCircleView)

        selectNumberCircleView.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.trailing.bottom.equalToSuperview().inset(10)
        }

        selectNumberCircleView.addSubview(selectNumberLabel)

        selectNumberLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
