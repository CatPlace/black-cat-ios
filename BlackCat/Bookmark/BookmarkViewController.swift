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
        rx.viewWillAppear
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)
        
        cancelRightBarButtonItem.rx.tap
            .bind(to: viewModel.didTapCancelBarButtonItem)
            .disposed(by: disposeBag)

        editRightBarButtonItem.rx.tap
            .withUnretained(self)
            .compactMap { owner, _ in
                owner.editRightBarButtonItem.title
            }.bind(to: viewModel.didTapEditBarButtonItem)
            .disposed(by: disposeBag)

        viewModel.updateModeDriver
            .drive(with: self) { owner, editMode in
                owner.updateEditButton(editMode: editMode)
                owner.updateCancelButton(editMode: editMode)
            }.disposed(by: disposeBag)
    }

    // MARK: - Functions

    private func updateEditButton(editMode: EditMode) {
        editRightBarButtonItem.title = editMode.rawValue
        editRightBarButtonItem.tintColor = editMode.tintColor
    }

    private func updateCancelButton(editMode: EditMode) {
        if editMode == .normal {
            cancelRightBarButtonItem.title = ""
            cancelRightBarButtonItem.isEnabled = false
        } else {
            cancelRightBarButtonItem.title = "취소"
            cancelRightBarButtonItem.isEnabled = true
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

    private let cancelRightBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem()
        barButtonItem.title = ""
        barButtonItem.tintColor = EditMode.normal.tintColor
        barButtonItem.isEnabled = false
        return barButtonItem
    }()

    private let editRightBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem()
        barButtonItem.title = EditMode.normal.rawValue
        barButtonItem.tintColor = EditMode.normal.tintColor
        return barButtonItem
    }()
}

extension BookmarkViewController {
    private func setNavigationBar() {
        navigationItem.title = "🖤 찜한 컨텐츠"
        navigationItem.rightBarButtonItems = [editRightBarButtonItem, cancelRightBarButtonItem]
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
