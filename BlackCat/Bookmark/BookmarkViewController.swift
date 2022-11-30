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
    case edit = "편집"
    case delete = "삭제"

    var tintColor: UIColor {
        switch self {
        case .edit: return .black
        case .delete: return .purple
        }
    }

    func toggle() -> EditMode {
        self == .edit
        ? .delete
        : .edit
    }
}

class BookmarkViewController: UIViewController {

    let disposeBag = DisposeBag()

    // MARK: - Properties

    let pages: [UIViewController]
    let viewModel = BookmarkViewModel(bookmarkPageViewModels: [BookmarkTattooViewModel(), BookmarkTattooViewModel()])
    var editMode: EditMode = .edit

    // MARK: - Binding

    private func bind(to viewModel: BookmarkViewModel) {
        editRightBarButtonItem.rx.tap
            .map { _ in self.editMode }
            .bind(to: viewModel.didTapEditBarButtonItem)
            .disposed(by: disposeBag)



        viewModel.updateModeDriver
            .drive(with: self) { owner, type in
                owner.editMode = type
                owner.updateButton(editMode: type)
            }.disposed(by: disposeBag)
    }

    // MARK: - Functions
    private func updateButton(editMode: EditMode) {
        editRightBarButtonItem.title = editMode.rawValue
        editRightBarButtonItem.tintColor = editMode.tintColor
    }
    private func toggleEditButton() {
        editMode = editMode == .edit
        ? .delete
        : .edit

        editRightBarButtonItem.title = editMode.rawValue
        editRightBarButtonItem.tintColor = editMode.tintColor
    }


    // MARK: - Initialize

    init() {
        self.pages = [
            BookmarkTattooViewController(viewModel: viewModel.bookmarkPageViewModels[0]),
            BookmarkMagazineViewController(viewModel: viewModel.bookmarkPageViewModels[1])
        ]

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
        button.title = "매거진"
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

    private let editRightBarButtonItem: UIBarButtonItem = {
        let barbuttonItem = UIBarButtonItem()
        barbuttonItem.title = EditMode.edit.rawValue
        barbuttonItem.tintColor = EditMode.edit.tintColor
        return barbuttonItem
    }()
}

extension BookmarkViewController {
    private func setNavigationBar() {
        title = "🖤 찜한 컨텐츠"
        navigationItem.rightBarButtonItem = editRightBarButtonItem
    }

    private func setUI() {
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
