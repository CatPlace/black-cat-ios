//
//  PresentationStyle.swift
//  BlackCat
//
//  Created by SeYeong on 2022/11/02.
//

import UIKit

enum PresentationStyle {
    case dropDown
    case dissolveAtCenter
}

extension PresentationStyle {
    func show(withConfiguration configuration: GenrePaperConfiguration) {
        switch self {
        case .dropDown:
            showDropDown(withConfiguration: configuration)
        case .dissolveAtCenter:
            showDissolve(withConfiguration: configuration)
        }
    }

    func hide(withConfiguration configuration: GenrePaperConfiguration) {
        switch self {
        case .dropDown:
            hideDropDown(withConfiguration: configuration)
        case .dissolveAtCenter:
            hideDissolve(withConfiguration: configuration)
        }
    }

    private func showDropDown(withConfiguration configuration: GenrePaperConfiguration) {
        let tableView = configuration.tableView
        let backgroundView = configuration.backgroundView

        UIView.animate(
            withDuration: configuration.animateDuration,
            delay: 0.1,
            options: .curveEaseInOut
        ) {
            tableView.frame.size.height = tableView.contentSize.height + configuration.dropDownCellInset.top + configuration.dropDownCellInset.bottom
            backgroundView.backgroundColor = .black.withAlphaComponent(0.24)
        }
    }

    private func hideDropDown(withConfiguration configuration: GenrePaperConfiguration) {
        let tableView = configuration.tableView
        let backgroundView = configuration.backgroundView
        let menuWrapper = configuration.menuWrapper

        UIView.animate(
            withDuration: configuration.animateDuration,
            delay: 0.1,
            options: .curveEaseInOut
        ) {
            backgroundView.backgroundColor = .black.withAlphaComponent(0)
            tableView.frame.size.height = 0
        } completion: { _ in
            menuWrapper.isHidden = true
        }
    }

    private func showDissolve(withConfiguration configuration: GenrePaperConfiguration) {
        let tableView = configuration.tableView
        let backgroundView = configuration.backgroundView
        tableView.alpha = 0

        UIView.animate(
            withDuration: configuration.animateDuration,
            delay: 0.1,
            options: .curveEaseInOut
        ) {
            backgroundView.backgroundColor = .black.withAlphaComponent(0.24)
            tableView.alpha = 1
        }
    }

    private func hideDissolve(withConfiguration configuration: GenrePaperConfiguration) {
        let tableView = configuration.tableView
        let backgroundView = configuration.backgroundView
        let menuWrapper = configuration.menuWrapper

        UIView.animate(
            withDuration: configuration.animateDuration,
            delay: 0.1,
            options: .curveEaseInOut
        ) {
            backgroundView.backgroundColor = .black.withAlphaComponent(0)
            tableView.alpha = 0
        } completion: { _ in
            menuWrapper.isHidden = true
        }
    }
}
