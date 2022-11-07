//
//  BPPriceInfoEditCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/06.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import SnapKit

// 🐻‍❄️ NOTE: - 다른 개발자님이 feature 이어 받으시도록 스타일로 맞춤.
final class BPPriceInfoEditTextCell: BaseTableViewCell {
    var disposeBag = DisposeBag()
    var viewModel: BPPriceInfoEditCellViewModel? {
        didSet {
            guard let viewModel else { print("💀 guard에 걸렸네요,,"); return; }
            
            viewModel.inputStringDriver
                .debug("😐")
                .drive(editTextView.rx.text)
                .disposed(by: disposeBag)
            
//            editTextView.rx.text
//                .bind(to: viewModel.editModelRelay)
//                .disposed(by: disposeBag)
        }
    }
    
    func setUI() {
        contentView.addSubview(editTextView)
        editTextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
//        editTextView.delegate = nil
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

final class BPPriceInfoEditCellViewModel {
    // MARK: - Input
    var editModelRelay: BehaviorRelay<BPPriceInfoEditModel>
    
    // MARK: - OutPut
    var inputStringDriver: Driver<String>
    
    init(editModelRelay: BehaviorRelay<BPPriceInfoEditModel>) {
        self.editModelRelay = editModelRelay
        
        self.inputStringDriver = editModelRelay
            .map { $0.input }
            .asDriver(onErrorJustReturn: "🚨 Error")
    }
}
