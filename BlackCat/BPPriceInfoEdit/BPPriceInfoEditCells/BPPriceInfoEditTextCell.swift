//
//  BPPriceInfoEditCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/06.
//

import UIKit
import ReactorKit
import SnapKit

// 🐻‍❄️ NOTE: - 다른 개발자님이 feature 이어 받으시도록 스타일로 맞춤.
final class BPPriceInfoEditTextCell: BaseTableViewCell, View {
    typealias Reactor = BPPriceInfoEditTextCellReactor
    
    var disposeBag = DisposeBag()
    
    func bind(reactor: Reactor) {
        reactor.state.map { $0.input }
            .withUnretained(self)
            .bind { owner, text in owner.editTextView.text = text }
            .disposed(by: disposeBag)
    }
    
    func setUI() {
        contentView.addSubview(editTextView)
        editTextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func initialize() {
        self.setUI()
    }
    
    lazy var editTextView: UITextView = {
        $0.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        $0.isScrollEnabled = false
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        
        return $0
    }(UITextView())
}

final class BPPriceInfoEditTextCellReactor: Reactor {
    typealias Action = NoAction
    
    var initialState: BPPriceInfoEditModel
    
    init(initialState: BPPriceInfoEditModel) {
        self.initialState = initialState
    }
}
