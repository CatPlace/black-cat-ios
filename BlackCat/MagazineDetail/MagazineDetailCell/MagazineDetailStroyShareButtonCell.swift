//
//  MagazineDetailButtonCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/09.
//

import UIKit
import ReactorKit
import SnapKit

final class MagazineDetailStroyShareButtonCell: MagazineDetailBaseCell, View {
    typealias Reactor = MagazineDetailStroyShareButtonCellReactor
    
    // MARK: - Binding
    func bind(reactor: Reactor) {
        print("binding")
        dispatch(reactor: reactor)
        render(reactor: reactor)
    }
    
    private func dispatch(reactor: Reactor) {
        stroyShareButton.rx.tap
            .debug("didTapTouched")
            .map { Reactor.Action.didTapShareButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
    
    private func render(reactor: Reactor) {
        reactor.state.compactMap { $0.isShowingShare }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .bind { owner, value in
                print("open share")
            }
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - Initialize
    override func initialize() {
        self.setUI()
    }
    
    // MARK: - UIComponents
    private let stroyShareButton = UIButton()
}

extension MagazineDetailStroyShareButtonCell {
    private func setUI() {
        addSubview(stroyShareButton)
        
        self.configureStroyShareButton(sender: stroyShareButton)
        
        let width = UIScreen.main.bounds.width * 3 / 7
        let heigth = UIScreen.main.bounds.width * 3 / 7 * 2 / 7
        stroyShareButton.snp.makeConstraints {
            $0.width.equalTo(width)
            $0.height.greaterThanOrEqualTo(heigth)
            $0.centerX.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
    }
    
    private func configureStroyShareButton(sender: UIButton) {
        sender.layer.cornerRadius = 12
        sender.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        sender.setTitle(" 스토리 공유", for: .normal)
        
        switch overrideUserInterfaceStyle {
        case .light, .unspecified:
            sender.tintColor = .systemBlue
            sender.setTitleColor(.systemBlue, for: .normal)
            sender.backgroundColor = .lightGray
        case .dark:
            sender.tintColor = .white
            sender.setTitleColor(.white, for: .normal)
            sender.backgroundColor = .gray
        @unknown default:
            assert(true, "✨")
        }
    }
}

final class MagazineDetailStroyShareButtonCellReactor: Reactor {

    enum Action {
        case didTapShareButton
    }
    
    enum Mutation {
        case isShowing(Bool)
    }
    
    struct State {
        var isShowingShare: Bool = false
    }

    var initialState: State

    init(initialState: State) {
        self.initialState = initialState
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTapShareButton:
            return .just(.isShowing(true))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .isShowing(let value):
            newState.isShowingShare = value
            return newState
        }
    }
}

