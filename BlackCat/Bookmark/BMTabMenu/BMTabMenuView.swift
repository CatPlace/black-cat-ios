//
//  KNButtonContainerView.swift
//  KidsNoteAssignment
//
//  Created by SeYeong on 2022/11/03.
//

import UIKit

import SnapKit

protocol BMTabMenuDelegate: AnyObject {
    func selectedButtonTag(tag: Int)
}

class BMTabMenuView: UIView {
    enum BarIndicatorWidthStyle {
        case full
        case half
        case quarter
    }

    // MARK: - Properties

    private let buttons: [BMTabButton]

    var currentSelectedButtonTag: Int? {
        didSet {
            guard let tag = currentSelectedButtonTag else { return }
            delegate?.selectedButtonTag(tag: tag)
            positionBarIndicator(at: tag)
            toggleButtonTintColor(tag: tag)
        }
    }

    var selectedColor: UIColor = .black.withAlphaComponent(1.0)

    var unSelectedColor: UIColor = .black.withAlphaComponent(0.3)

    var barIndicatorHeight: CGFloat = 4.0

    var barIndicatorWidth: CGFloat = UIScreen.main.bounds.width / 2

    weak var delegate: BMTabMenuDelegate?

    // MARK: - Functions

    private func positionBarIndicator(at tag: Int) {
        barIndicator.snp.remakeConstraints {
            $0.centerX.equalTo(buttons[tag])
            $0.width.equalTo(barIndicatorWidth)
            $0.height.equalTo(barIndicatorHeight)
            $0.bottom.equalToSuperview()
        }

        UIView.animate(withDuration: 0.35) {
            self.layoutIfNeeded()
        }
    }

    private func toggleButtonTintColor(tag: Int) {
        buttons.forEach { button in
            if button.tag == tag {
                button.tintColor = selectedColor
            } else {
                button.tintColor = unSelectedColor
            }
        }
    }

    private func setupButtons(_ buttons: [BMTabButton]) {
        buttons.enumerated().forEach { index, button in
            button.delegate = self
            button.tag = index
        }
        toggleButtonTintColor(tag: 0)
    }

    // MARK: - Initialize

    init(buttons: [BMTabButton]) {
        self.buttons = buttons
        currentSelectedButtonTag = buttons.first?.tag

        super.init(frame: .zero)
        setupButtons(buttons)
        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIComponents

    private let buttonStackView = UIStackView()
    let barIndicator = BMTabBarIndicator()
}

// MARK: - Layout

extension BMTabMenuView {
    private func setUI() {
        [buttonStackView, barIndicator].forEach { addSubview($0) }

        buttonStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttons.forEach { buttonStackView.addArrangedSubview($0) }

        barIndicator.snp.makeConstraints {
            $0.centerX.equalTo(buttons.first ?? 0)
            $0.width.equalTo(barIndicatorWidth)
            $0.height.equalTo(barIndicatorHeight)
            $0.bottom.equalToSuperview()
        }
    }
}

// MARK: - Delegate

extension BMTabMenuView: BMTabButtonDelegate {
    func didSelectButton(tag: Int) {
        currentSelectedButtonTag = tag
        delegate?.selectedButtonTag(tag: tag)
    }
}
