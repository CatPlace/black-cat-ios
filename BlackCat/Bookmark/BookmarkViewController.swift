//
//  BookmarkViewController.swift
//  BlackCat
//
//  Created by SeYeong on 2022/11/10.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

enum EditMode: String {
    case normal = "편집"
    case edit = "삭제"

    var tintColor: UIColor {
        switch self {
        case .normal: return .black
        case .edit: return .purple
        }
    }

    func toggle() -> EditMode {
        self == .normal
        ? .edit
        : .normal
    }
    
    func asStringInTattooEdit() -> String {
        switch self {
        case .normal: return "편집"
        case .edit: return "완료"
        }
    }
}

class BookmarkViewController: UIViewController {

    let disposeBag = DisposeBag()

    // MARK: - Properties

    let pages: [UIViewController]
    var viewModel: BookmarkViewModel

    // MARK: - Binding

    private func bind(to viewModel: BookmarkViewModel) {
        cancelRightBarLabel.rx.tapGesture()
            .when(.recognized)
            .map { _ in () }
            .bind(to: viewModel.didTapCancelBarButtonItem)
            .disposed(by: disposeBag)

        editRightBarLabel.rx.tapGesture()
            .when(.recognized)
            .withUnretained(self)
            .compactMap { owner, _ in
                owner.editRightBarLabel.text
            }.bind(to: viewModel.didTapEditBarButtonItem)
            .disposed(by: disposeBag)

        viewModel.updateModeDriver
            .drive(with: self) { owner, editMode in
                owner.updateEditButton(editMode: editMode)
                owner.updateCancelButton(editMode: editMode)
            }.disposed(by: disposeBag)
        
        // TODO: - postType별 id로 상세페이지 들어가기
        viewModel.showTattooDetailVCDriver
            .drive(with: self) { owner, tattooId in
                let vc = TattooDetailViewController(viewModel: .init(tattooId: tattooId))
                owner.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: disposeBag)
        
        viewModel.showTattooistDetailVCDriver
            .drive(with: self) { owner, tattooistId in
                let vc = JHBusinessProfileViewController(viewModel: .init(tattooistId: tattooistId))
                owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }

    // MARK: - Functions
    private func updateEditButton(editMode: EditMode) {
        editRightBarLabel.text = editMode.rawValue
        editRightBarLabel.textColor = editMode.tintColor
    }

    private func updateCancelButton(editMode: EditMode) {
        if editMode == .normal {
            cancelRightBarLabel.text = ""
            cancelRightBarLabel.isUserInteractionEnabled = false
        } else {
            cancelRightBarLabel.text = "취소"
            cancelRightBarLabel.isUserInteractionEnabled = true
        }
    }

    // MARK: - Initialize
    init(viewModel: BookmarkViewModel = .init()) {
        self.viewModel = viewModel
        self.pages = viewModel.bookmarkPageViewModels.map { BookmarkPostViewController(viewModel: $0) }

        super.init(nibName: nil, bundle: nil)
        bind(to: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        setUI()
        setPageViewController()
    }

    // MARK: - UIComponents

    private let pageViewConroller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)

    private let tattooTabMenuButton: BMTabButton = {
        let button = BMTabButton()
        button.title = "타투"
        return button
    }()

    private let magazineTabMenuButton: BMTabButton = {
        let button = BMTabButton()
        button.title = "타투이스트"
        return button
    }()

    private lazy var tabMenuView: BMTabMenuView = {
        let view = BMTabMenuView(buttons: [tattooTabMenuButton, magazineTabMenuButton])
        view.selectedColor = .black
        view.unSelectedColor = .black.withAlphaComponent(0.3)
        view.barIndicator.tintColor = .black
        view.delegate = self
        return view
    }()

    private let contentView = UIView()

    private let cancelRightBarLabel: UILabel = {
        let label = UILabel(frame: .init(origin: .zero, size: .init(width: 38, height: 20)))
        label.text = ""
        label.textColor = .init(hex: "#C4C4C4FF")
        label.font = .appleSDGoithcFont(size: 16, style: .semiBold)
        return label
    }()

    private let editRightBarLabel: UILabel = {
        let label = UILabel()
        label.text = EditMode.normal.rawValue
        label.textColor = EditMode.normal.tintColor
        label.font = .appleSDGoithcFont(size: 16, style: .semiBold)
        return label
    }()
}

extension BookmarkViewController {
    private func setNavigationBar() {
        appendNavigationLeftLabel(title: "찜 목록", color: .black)
        appendNavigationRightLabel(editRightBarLabel)
        appendNavigationRightLabel(cancelRightBarLabel)
    }

    private func setUI() {
        view.backgroundColor = .white

        view.addSubview(tabMenuView)

        tabMenuView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        view.addSubview(contentView)

        contentView.snp.makeConstraints {
            $0.top.equalTo(tabMenuView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func setPageViewController() {
        contentView.addSubview(pageViewConroller.view)

        pageViewConroller.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        pageViewConroller.setViewControllers([pages[0]], direction: .forward, animated: false)
        pageViewConroller.scrollView?.isScrollEnabled = false
    }
}

extension BookmarkViewController: BMTabMenuDelegate {
    func selectedButtonTag(tag: Int) {
        pageViewConroller.setViewControllers([pages[tag]], direction: .forward, animated: false)
        viewModel.currentShowingPageIndex.accept(tag)
    }
}
