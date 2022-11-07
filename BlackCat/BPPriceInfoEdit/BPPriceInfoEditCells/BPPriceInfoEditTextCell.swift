//
//  BPPriceInfoEditCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/06.
//

import Foundation
import UIKit
import RxSwift
import RxRelay
import RxCocoa

struct TextCellViewModel {
    let inpurString: BehaviorRelay<String>
    
    init(inpurString: BehaviorRelay<String>) {
        self.inpurString = inpurString
    }
}

// 🐻‍❄️ NOTE: - 다른 개발자님이 feature 이어 받으시도록 스타일로 맞춤.
final class BPPriceInfoEditTextCell: BaseTableViewCell {
    var disposeBag = DisposeBag()
    
//    var item: BPPriceInfoEditModel? {
//        didSet { configureCell() }
//    }
//    
//    private func configureCell() {
//        guard let item else { return }
//        editTextView.text = "\(item.row)" + item.input
//    }
    
    func bind(to viewModel: TextCellViewModel) {
        editTextView.rx.text.orEmpty
            .bind(to: viewModel.inpurString)
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
