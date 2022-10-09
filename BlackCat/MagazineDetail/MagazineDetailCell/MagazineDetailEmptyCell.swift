//
//  MagazineDetailEmptyCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/08.
//

import UIKit
import ReactorKit
import SnapKit

final class MagazineDetailEmptyCell: MagazineDetailBaseCell, View {
    typealias Reactor = MagazineDetailEmptyCellReactor
    
    // MARK: - Binding
    func bind(reactor: Reactor) {
        reactor.state.compactMap { $0 }
            .withUnretained(self)
            .bind { owner, item in
                print("item.emptyHeight \(item.emptyHeight)")
                var emptyView = UIView()
                emptyView = UIView(frame: CGRect(x: 0,
                                                 y: 0,
                                                 width: Int(self.frame.width),
                                                 height: item.emptyHeight))
                 
                self.setUI(item.emptyHeight)
            }
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - Initalizing
    override func initialize() {
//        self.setUI()
    }
   
    // MARK: - UIComponents
    private var emptyView = UIView()
}

extension MagazineDetailEmptyCell {
    func setUI(_ height: Int) {
        addSubview(emptyView)

        emptyView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(10)
            $0.height.greaterThanOrEqualTo(height).priority(750)
            $0.bottom.equalToSuperview().inset(10).priority(1000)
        }
    }
}

final class MagazineDetailEmptyCellReactor: Reactor {
    typealias Action = NoAction

    var initialState: MagazineDetailModel

    init(initialState: MagazineDetailModel) {
        self.initialState = initialState
    }
    
//    func reduce(state: State, mutation: NoAction) -> State {
//        var newState = state
//        newState.height = currentState.height
//        return newState
//    }
}
