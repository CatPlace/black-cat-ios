//
//  BPProfileEditViewController.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/05.
//

import UIKit
import SnapKit
import ReactorKit

final class BPProfileEditViewController: UIViewController, View {
    var disposeBag: DisposeBag = DisposeBag()
    
    typealias Reactor = BPProfileEditReactor
    
    func bind(reactor: Reactor) {
        dispatch(reactor: reactor)
        render(reactor: reactor)
    }
    
    func dispatch(reactor: Reactor) {
        closeBarButtonItem.rx.tap
            .map { Reactor.Action.didTapClose }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
    }
    
    func render(reactor: Reactor) {
        reactor.state.map { $0.isDismiss }
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe { owner, isDissmiss in
                print("🐬 isDismiss \(isDissmiss)")
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
    }
    
    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    lazy var closeBarButtonItem: UIBarButtonItem = {
        $0.image = UIImage(systemName: "xmark")
        $0.style = .plain
        $0.target = self
        $0.tintColor = .black
        return $0
    }(UIBarButtonItem())
    
    lazy var imageBarButtonItem: UIBarButtonItem = {
        $0.image = UIImage(systemName: "photo")
        $0.style = .plain
        $0.target = self
        $0.tintColor = .black
        return $0
    }(UIBarButtonItem())
    
    lazy var BPEditTextView: UITextView = {
        $0.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        return $0
    }(UITextView())
}

extension BPProfileEditViewController {
    func setUI() {
        navigationController?.isToolbarHidden = false
        self.navigationItem.leftBarButtonItems = [closeBarButtonItem]
        self.toolbarItems = [imageBarButtonItem]
        
        view.addSubview(BPEditTextView)
        BPEditTextView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

final class BPProfileEditReactor: Reactor {
    enum Action {
        case didTapClose
    }
    
    enum Mutation {
        case isDismiss
    }
    
    struct State {
        var isDismiss = false
    }
    
    var initialState: State
    
    init(initialState: State) {
        self.initialState = initialState
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTapClose: return .just(.isDismiss)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .isDismiss:
            newState.isDismiss = true
            return newState
        }
    }
}
