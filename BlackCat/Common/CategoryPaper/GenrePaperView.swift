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
class GenrePaperView: UIView {

    // MARK: - Properties

    var presentationStyle: PresentationStyle {
        get {
            self.configuration.presentationStyle
        } set(newStyle) {
            self.setPresentationView(style: newStyle)
            self.configuration.presentationStyle = newStyle
        }
    }

    var dropDownBackgroundColor: UIColor? {
        get {
            self.configuration.backgroundColor
        } set(newColor) {
            self.configuration.backgroundColor = newColor
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
            guard presentationStyle == .dropDown else { return }
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
            setPresentationView(style: presentationStyle)
            configuration.tableView.reloadData()
        }
    }

    // MARK: - Functions

    func configure(with items: [String], title: String) {
        self.items = items
        genreTitleLabel.text = title
    }

    @objc
    private func didTapGenreTitleView() {
        if isShown {
            hidePresentationView()
        } else {
            showPresentationView()
        }
    }

    @objc
    private func didTapBackgroundView() {
        if isShown { presentationStyle.hide(withConfiguration: configuration) }
    }

    func showPresentationView() {
        isShown = true
        rotateArrowImage()
        configuration.menuWrapper.isHidden = false
        presentationStyle.show(withConfiguration: configuration)
    }

    func hidePresentationView() {
        isShown = false
        rotateArrowImage()
        presentationStyle.hide(withConfiguration: configuration)
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

        tableViewFrame = self.globalFrame ?? .zero
    }

    // MARK: - UIComponents

    let configuration = GenrePaperConfiguration()

    private let genreTitleView = UIView()

    let genreTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        let arrowImage = UIImage(systemName: "arrowtriangle.down.fill")
        imageView.tintColor = .black
        arrowImage?.withRenderingMode(.alwaysOriginal)
        imageView.image = arrowImage
        return imageView
    }()
}

extension GenrePaperView {
    private func setUI() {
        let dismissListGesture = UITapGestureRecognizer(target: self,
                                                        action: #selector(didTapGenreTitleView))
        let backgroundView = configuration.backgroundView

        backgroundView.addGestureRecognizer(dismissListGesture)

        addSubview(genreTitleView)
        genreTitleView.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        genreTitleView.addGestureRecognizer(
            UITapGestureRecognizer(target: self,action: #selector(didTapGenreTitleView))
        )

        genreTitleView.addSubview(arrowImageView)

        arrowImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(18)
            $0.leading.equalTo(genreTitleView.snp.trailing).offset(10)
            $0.width.equalTo(10)
            $0.height.equalTo(10)
        }

        genreTitleView.addSubview(genreTitleLabel)

        genreTitleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(8)
            $0.trailing.equalTo(arrowImageView.snp.leading).offset(-10)
        }

        setPresentationView(style: presentationStyle)
    }

    private func setPresentationView(style: PresentationStyle) {
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
            let height = cellHeight * CGFloat(items.count) + 40
            let tableViewXPoint = (menuWrapper.bounds.width / 2) - (width / 2)
            let tableViewYPoint = (menuWrapper.bounds.height / 2) - (height / 2)
            tableView.frame = CGRect(x: tableViewXPoint, y: tableViewYPoint, width: width, height: height)
        }
    }
}

extension Reactive where Base: GenrePaperView {
    var itemSelected: ControlEvent<IndexPath> {
        return base.configuration.tableView.rx.itemSelected
    }
}
