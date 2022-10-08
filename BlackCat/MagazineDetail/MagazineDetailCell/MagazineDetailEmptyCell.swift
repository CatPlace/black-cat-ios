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
                owner.emptyView = UIView(frame: CGRect(x: 0,
                                                       y: 0,
                                                       width: Int(owner.frame.width),
                                                       height: item.emptyHeight))
                
                owner.setUI()
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
    func setUI() {
        addSubview(emptyView)
        emptyView.backgroundColor = .orange
        
        emptyView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}

final class MagazineDetailEmptyCellReactor: Reactor {

    typealias Action = NoAction

    var initialState: MagazineDetailModel

    init(initialState: MagazineDetailModel) {
        self.initialState = initialState
    }
}
