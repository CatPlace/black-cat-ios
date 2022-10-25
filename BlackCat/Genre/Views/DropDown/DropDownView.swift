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

/// intrinsic size가 있습니다.
class DropDownView: UIView {

    // MARK: - Properties

    var listBackgroundColor: UIColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1) {
        didSet {
            tableView.backgroundColor = listBackgroundColor
        }
    }

    private var _animateDuration: TimeInterval = 0.35
    var animateDuration: TimeInterval {
        get {
            return _animateDuration
        } set(duration) {
            _animateDuration = duration
        }
    }

    var rowHeight: CGFloat = 28 {
        didSet {
            tableView.rowHeight = rowHeight
        }
    }

    var tableViewContentInset: UIEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0) {
        didSet {
            tableView.contentInset = tableViewContentInset
        }
    }

    var width: CGFloat = 130

    private lazy var tableViewFrame: CGRect = CGRect(x: 0, y: 0, width: width, height: 0) {
        didSet {
            self.tableView.frame = CGRect(x: tableViewFrame.origin.x, y: tableViewFrame.origin.y + tableViewFrame.height, width: width, height: 0)
        }
    }
    private var isShown: Bool = false
    private var items: [String] = [] {
        didSet {
            tableView.reloadData()
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
        menuWrapper.isHidden = false
        rotateArrowImage()

        UIView.animate(withDuration: _animateDuration, delay: 0.1, options: .curveEaseInOut) {
            self.tableView.frame.size.height = self.tableView.contentSize.height + self.tableViewContentInset.top + self.tableViewContentInset.bottom
            self.backgroundView.backgroundColor = .black.withAlphaComponent(0.24)
        }
    }

    func hideList() {
        isShown = false
        rotateArrowImage()

        UIView.animate(withDuration: _animateDuration, delay: 0.1, options: .curveEaseInOut) {
            self.backgroundView.backgroundColor = .black.withAlphaComponent(0)
            self.tableView.frame.size.height = 0
        } completion: { _ in
            self.menuWrapper.isHidden = true
        }
    }

    private func rotateArrowImage() {
        UIView.animate(withDuration: _animateDuration) {
            self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: 180 * CGFloat(Double.pi/180))
        }
    }

    // MARK: - Initializig

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        print(#function)

        categoryTitleView.snp.updateConstraints {
            $0.width.equalTo(width)
        }
        tableViewFrame = self.globalFrame ?? .zero
    }

    // MARK: - UIComponents

    private let categoryTitleView = UIView()
    private let categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        let arrowImage = UIImage(systemName: "arrowtriangle.down.fill")?.withRenderingMode(.alwaysOriginal)
        imageView.image = arrowImage
        return imageView
    }()
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    private let menuWrapper = UIView()
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(DropDownTableViewCell.self,
                           forCellReuseIdentifier: "DropDownTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = listBackgroundColor
        tableView.rowHeight = rowHeight
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 15
        tableView.contentInset = tableViewContentInset
        tableView.isScrollEnabled = false
        return tableView
    }()
}

extension DropDownView {
    func setUI() {
        guard let window = UIApplication.shared.keyWindow else { return }
        let dismissListGesture = UITapGestureRecognizer(target: self,
                                                        action: #selector(didTapCategoryTitleView))
        backgroundView.addGestureRecognizer(dismissListGesture)

        addSubview(categoryTitleView)
        categoryTitleView.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.width.equalTo(width)
            $0.trailing.equalToSuperview()
        }
        categoryTitleView.addGestureRecognizer(
            UITapGestureRecognizer(target: self,action: #selector(didTapCategoryTitleView))
        )

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

        window.addSubview(menuWrapper)
        menuWrapper.frame = window.bounds
        menuWrapper.isHidden = true

        menuWrapper.addSubview(backgroundView)
        backgroundView.frame = window.bounds

        menuWrapper.addSubview(tableView)
        tableView.frame = tableViewFrame
    }
}

extension DropDownView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownTableViewCell",
                                                       for: indexPath)
                as? DropDownTableViewCell else { return UITableViewCell() }

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

extension UIView {
    var globalFrame: CGRect? {
        let rootView = UIApplication.shared.keyWindow?.rootViewController?.view
        return self.superview?.convert(self.frame, to: rootView)
    }
}
