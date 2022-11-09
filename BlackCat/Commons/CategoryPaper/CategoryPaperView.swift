//
//  DropDownView.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/23.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

/// intrinsic size가 있습니다.
class CategoryPaperView: UIView {

    // MARK: - Properties

    var presentStyle: PresentStyle {
        get {
            self.configuration.presentStyle
        } set(newStyle) {
            self.setPresentationView(style: newStyle)
            self.configuration.presentStyle = newStyle
        }
    }

    var dropDownBackgroundColor: UIColor? {
        get {
            self.configuration.dropDownBackgroundColor
        } set(newColor) {
            self.configuration.dropDownBackgroundColor = newColor
        }
    }

    var animateDuration: TimeInterval {
        get {
            configuration.animateDuration
        } set(duration) {
            configuration.animateDuration = duration
        }
    }

    var cellHeight: CGFloat {
        get {
            configuration.cellHeight
        } set {
            configuration.cellHeight = newValue
        }
    }

    var cellInset: UIEdgeInsets {
        get {
            configuration.dropDownCellInset
        } set {
            configuration.dropDownCellInset = newValue
        }
    }

    var width: CGFloat {
        get {
            configuration.width
        } set {
            configuration.width = newValue
        }
    }

    private lazy var tableViewFrame: CGRect = CGRect(x: 0, y: 0, width: width, height: 0) {
        didSet {
            guard presentStyle == .dropDown else { return }
            let tableView = configuration.tableView
            tableView.frame = CGRect(x: tableViewFrame.origin.x,
                                     y: tableViewFrame.origin.y + tableViewFrame.height,
                                     width: width,
                                     height: 0)
        }
    }
    
    private var isShown: Bool = false

    var items: [String] = [] {
        didSet {
            configuration.tableView.reloadData()
        }
    }

    // MARK: - Functions

    func configure(with items: [String]) {
        self.items = items
        categoryTitleLabel.text = items.first ?? ""
    }

    @objc
    private func didTapCategoryTitleView() {
        if isShown {
            hidePresentationView()
        } else {
            showPresentationView()
        }
    }

    @objc
    private func didTapBackgroundView() {
        if isShown { presentStyle.hide(withConfiguration: configuration) }
    }

    func showPresentationView() {
        isShown = true
        rotateArrowImage()
        configuration.menuWrapper.isHidden = false
        presentStyle.show(withConfiguration: configuration)
    }

    func hidePresentationView() {
        isShown = false
        rotateArrowImage()
        presentStyle.hide(withConfiguration: configuration)
    }

    private func rotateArrowImage() {
        UIView.animate(withDuration: animateDuration) {
            self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: 180 * CGFloat(Double.pi/180))
        }
    }

    // MARK: - Initializig

    override init(frame: CGRect) {
        super.init(frame: frame)
        configuration.tableView.dataSource = self
        configuration.tableView.delegate = self
        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        categoryTitleView.snp.updateConstraints {
            $0.width.equalTo(width)
        }
        tableViewFrame = self.globalFrame ?? .zero
    }

    // MARK: - UIComponents

    let configuration = CategoryPaperConfiguration()

    private let categoryTitleView = UIView()

    let categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        let arrowImage = UIImage(systemName: "arrowtriangle.down.fill")
        arrowImage?.withRenderingMode(.alwaysOriginal)
        imageView.image = arrowImage
        return imageView
    }()
}

extension CategoryPaperView {
    private func setUI() {
        let dismissListGesture = UITapGestureRecognizer(target: self,
                                                        action: #selector(didTapCategoryTitleView))
        let backgroundView = configuration.backgroundView

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

        setPresentationView(style: presentStyle)
    }

    private func setPresentationView(style: PresentStyle) {
        guard let window = UIApplication.shared.keyWindow else { return }

        let backgroundView = configuration.backgroundView
        let menuWrapper = configuration.menuWrapper
        let tableView = configuration.tableView

        window.addSubview(menuWrapper)
        menuWrapper.frame = window.bounds
        menuWrapper.isHidden = true

        menuWrapper.addSubview(backgroundView)
        menuWrapper.addSubview(tableView)
        backgroundView.frame = window.bounds

        switch style {
        case .dropDown:
            tableView.frame = tableViewFrame
        case .dissolveAtCenter:
            let tableViewXPoint = (menuWrapper.bounds.width / 2) - (width / 2)
            let tableViewYPoint = (menuWrapper.bounds.height / 2) - 200
            tableView.frame = CGRect(x: tableViewXPoint, y: tableViewYPoint, width: width, height: 400)
        }
    }
}

extension Reactive where Base: CategoryPaperView {
    var itemSelected: ControlEvent<IndexPath> {
        return base.configuration.tableView.rx.itemSelected
    }
}
