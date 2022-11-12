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

protocol BPPriceInfoEditTextCellProtocol {
    func textViewDidChange(text: String)
}

// 🐻‍❄️ NOTE: - 다른 개발자님이 feature 이어 받으시도록 스타일로 맞춤.
final class BPPriceInfoEditTextCell: BaseTableViewCell {
    var disposeBag = DisposeBag()
    var delegate: BPPriceInfoEditTextCellProtocol?
    
    var viewModel: BPPriceInfoEditCellViewModel? {
        didSet {
            guard let viewModel else { print("💀 guard에 걸렸네요,,"); return; }
            
            viewModel.inputStringDriver
                .distinctUntilChanged() // 이건 스트림 분기
//                .debug("😐")
                .drive(editTextView.rx.text)
                .disposed(by: disposeBag)
            
            editTextView.rx.text.orEmpty
                .withUnretained(self)
                .map { owner, text -> BPPriceInfoEditModel in
                    owner.delegate?.textViewDidChange(text: text)
                    
                    return .init(row: 0, type: .text, input: text)
                }
                .bind(to: viewModel.editModelRelay)
                .disposed(by: disposeBag)
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
        $0.autocorrectionType = .no // 자동완성 없애기
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textContainer.maximumNumberOfLines = 0
        $0.delegate = self
        
        return $0
    }(UITextView())
}
extension BPPriceInfoEditTextCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print(text)
        if let char = text.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92 && self.editTextView.text.isEmpty) {
                self.editTextView.resignFirstResponder()
                
                return true
            }
        }
        return true
    }
}

final class BPPriceInfoEditCellViewModel {
    // MARK: - Input
    var editModelRelay: BehaviorRelay<BPPriceInfoEditModel>
    
    // MARK: - OutPut
    var inputStringDriver: Driver<String>
    var imageDriver: Driver<UIImage>
    
    init(editModelRelay: BehaviorRelay<BPPriceInfoEditModel>) {
        self.editModelRelay = editModelRelay
        
        self.inputStringDriver = editModelRelay
            .map { $0.input }
            .asDriver(onErrorJustReturn: "🚨 Error")
        
        self.imageDriver = editModelRelay
            .map { $0.image }
            .asDriver(onErrorJustReturn: UIImage())
    }
}
