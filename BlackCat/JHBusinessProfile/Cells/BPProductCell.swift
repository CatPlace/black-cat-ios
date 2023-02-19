//
//  BPProductCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import Nuke
import BlackCatSDK

// 🐻‍❄️ NOTE: - 다른 개발자님이 feature 이어 받으시도록 스타일로 맞춤.
class BPProductCellViewModel {
    
    var imageUrlString: String
    
    var editMode: BehaviorRelay<EditMode>
    var isSelectEditViewRelay = BehaviorRelay<Bool>(value: false)
    var editCountRelay = BehaviorRelay<Int?>(value: nil)
    
    var editViewIsHiddenDrvier: Driver<Bool>
    var editViewSelectDriver: Driver<Bool>
    var editCountLabelTextDriver: Driver<String>
    
    init(editMode: BehaviorRelay<EditMode>, product: Model.TattooThumbnail) {
        self.editMode = editMode
        self.imageUrlString = product.imageUrlString
        editViewIsHiddenDrvier = editMode
            .map { $0 == .normal }
            .asDriver(onErrorJustReturn: false)
        
        editViewSelectDriver = isSelectEditViewRelay
            .asDriver(onErrorJustReturn: false)
        
        editCountLabelTextDriver = editCountRelay
            .compactMap { $0 }
            .map { "\($0)" }
            .asDriver(onErrorJustReturn: "")
    }
}

final class BPProductCell: BPBaseCollectionViewCell {
    // MARK: - Function
    var viewModel: BPProductCellViewModel?
    // MARK: - Binding
    func bind(to viewModel: BPProductCellViewModel) {
        self.viewModel = viewModel
        loadImageUsingNuke(sender: productImageView, urlString: viewModel.imageUrlString)
        
        viewModel.editViewIsHiddenDrvier
            .drive(editView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.editCountLabelTextDriver
            .drive(with: self) { owner, text in
                owner.updateEditCount(with: text)
            }.disposed(by: disposeBag)
        
        viewModel.editViewSelectDriver
            .drive(with: self) { owner, isSelected in
                owner.editView.backgroundColor = isSelected ? .black.withAlphaComponent(0.5) : .clear
                owner.updateEditCountLabelUI(with: isSelected)
            }.disposed(by: disposeBag)
    }
    
    func updateEditCount(with text: String) {
        editCountLabel.font = .appleSDGoithcFont(size: 16 / CGFloat(text.count), style: .bold)
        editCountLabel.text = text
    }
    func updateEditCountLabelUI(with isSelected: Bool) {
        editCountLabel.backgroundColor = isSelected ? .white : .clear
        if !isSelected {
            editCountLabel.text = ""
        }
    }
    // MARK: - Initializer
    override func initialize() {
        self.setUI()
    }
    
    // MARK: - Life Cycle
    override func prepareForReuse() {
        productImageView.image = nil
        disposeBag = DisposeBag()
    }
    
    // MARK: - UIComponents
    lazy var productImageView: UIImageView = {
        $0.layer.backgroundColor = UIColor.gray.cgColor
        return $0
    }(UIImageView())
    
    let editView = UIView()
    let editCountLabel: UILabel = {
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.font = .appleSDGoithcFont(size: 16, style: .bold)
        $0.textColor = .init(hex: "#7210A0FF")
        $0.backgroundColor = .white
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    func setUI() {
        contentView.addSubview(productImageView)
        contentView.addSubview(editView)
        
        productImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        editView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        editView.addSubview(editCountLabel)
        
        editCountLabel.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().inset(10)
            $0.width.height.equalTo(20)
        }
    }
}
