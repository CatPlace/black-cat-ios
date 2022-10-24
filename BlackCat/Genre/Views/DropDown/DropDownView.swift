//
//  DropDownView.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/23.
//

import UIKit

import RxSwift
import SnapKit
import RxCocoa

class DropDownView: UIView {

    // MARK: - Properties

    var separatorBackgroundColor: UIColor = .black {
        didSet {
            separatorView.backgroundColor = separatorBackgroundColor
        }
    }

    var listBackgroundColor: UIColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1) {
        didSet {
            contentView.backgroundColor = listBackgroundColor
            tableView.backgroundColor = listBackgroundColor
        }
    }

    var animateDuration: TimeInterval {
        get {
            return _animateDuration
        } set(duration) {
            _animateDuration = duration
        }
    }

    let titleFrame: CGRect
    private var _animateDuration: TimeInterval = 0.8
    private let categoryTitleViewHeight: CGFloat = 30
    private let rowHeight: CGFloat = 28
    private let separatorTopPadding: CGFloat = 8
    private var isShown: Bool = false
    private var items: [String] = ["1", "2", "3", "4", "5", "이거 좀 단어 길다 조심해!!!"] {
        didSet {
            tableView.reloadData()
            tableView.snp.updateConstraints {
                $0.height.equalTo(tableView.contentSize.height)
            }
        }
    }

    // MARK: - Functions

    func configure(with items: [String]) {
        self.items = items
        categoryTitleLabel.text = items.first ?? ""
    }

    @objc
    private func didTapCategoryTitleView() {
        print(#function)
        isShown ? hideList() : showList()
    }

    @objc
    private func didTapBackgroundView() {
        print(#function)
        if isShown { hideList() }
    }

    func showList() {
        isShown = true
        self.backgroundView.isHidden = false
        updateBackgroundViewHeight(to: 0)
        superview?.layoutIfNeeded()

        contentView.isHidden = false
        updateBackgroundViewHeight(to: tableView.contentSize.height + categoryTitleViewHeight + separatorTopPadding)
        rotateArrowImage()

        UIView.animate(withDuration: _animateDuration, delay: 0, options: .curveEaseInOut) {
            self.backgroundView.backgroundColor = .black.withAlphaComponent(0.4)
            self.superview?.layoutIfNeeded()
        }
    }

    func hideList() {
        isShown = false
        updateBackgroundViewHeight(to: 0)
        rotateArrowImage()

        UIView.animate(withDuration: _animateDuration, delay: 0, options: .curveEaseInOut) {
            self.backgroundView.backgroundColor = .black.withAlphaComponent(0)
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            self.backgroundView.isHidden = true
            self.contentView.isHidden = true
            self.updateBackgroundViewHeight(to: self.categoryTitleViewHeight)
            self.layoutIfNeeded()
        }
    }

    private func rotateArrowImage() {
        UIView.animate(withDuration: _animateDuration) {
            self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: 180 * CGFloat(Double.pi/180))
        }
    }

    private func updateBackgroundViewHeight(to height: CGFloat) {
        contentView.snp.updateConstraints {
            $0.height.equalTo(height)
        }
    }

    // MARK: - Initializig

    init(listFrame: CGRect) {
        self.titleFrame = listFrame

        super.init(frame: .zero)
        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIComponents

    private let categoryTitleView = UIView()
    private let categoryTitleLabel = UILabel()
    private let arrowImageView = UIImageView(image: UIImage(systemName: "arrowtriangle.down.fill")?.withRenderingMode(.alwaysOriginal))
    private let backgroundView = UIView()
    private let contentView = UIView()
    let tableView = UITableView()
    private let separatorView = UIView()
}

extension DropDownView {
    func setUI() {
        addSubview(backgroundView)

        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        backgroundView.backgroundColor = .black.withAlphaComponent(0)
        backgroundView.isHidden = true
        let dismissListGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundView))
        backgroundView.addGestureRecognizer(dismissListGesture)

        addSubview(contentView)

        contentView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(titleFrame.origin.y)
            $0.leading.equalToSuperview().inset(titleFrame.origin.x)
            $0.width.equalTo(titleFrame.size.width)
            $0.height.equalTo(titleFrame.size.height)
        }

        print("bgFrame:", contentView.frame)
        contentView.backgroundColor = listBackgroundColor
        contentView.clipsToBounds = true
        contentView.isHidden = true
        contentView.layer.cornerRadius = 15

        addSubview(categoryTitleView)

        categoryTitleView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(contentView)
            $0.height.equalTo(titleFrame.size.height)
        }
        categoryTitleView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                      action: #selector(didTapCategoryTitleView)))

        categoryTitleView.addSubview(arrowImageView)

        arrowImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(18)
            $0.trailing.equalToSuperview().inset(10)
            $0.width.equalTo(10)
            $0.height.equalTo(10)
        }

        categoryTitleView.addSubview(categoryTitleLabel)

        categoryTitleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(8)
            $0.trailing.equalTo(arrowImageView.snp.leading).offset(-10)
        }
        categoryTitleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        categoryTitleLabel.adjustsFontSizeToFitWidth = true

        contentView.addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(titleFrame.size.height + 2)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(rowHeight * CGFloat(items.count))
        }

        tableView.register(DropDownTableViewCell.self,
                           forCellReuseIdentifier: "DropDownTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.rowHeight = rowHeight
        tableView.backgroundColor = listBackgroundColor
        tableView.separatorStyle = .none

        contentView.addSubview(separatorView)

        separatorView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(titleFrame.size.height)
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(1)
        }

        separatorView.backgroundColor = separatorBackgroundColor
    }
}

extension DropDownView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownTableViewCell", for: indexPath) as? DropDownTableViewCell else { return UITableViewCell() }

        cell.configure(with: items[indexPath.row])

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hideList()
        categoryTitleLabel.text = items[indexPath.row]
    }
}


extension Reactive where Base: DropDownView {
    var itemSelected: ControlEvent<IndexPath> {
        return base.tableView.rx.itemSelected
    }
}
