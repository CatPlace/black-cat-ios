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
    var editMode: BehaviorRelay<EditMode>
    var isSelectEditViewRelay = BehaviorRelay<Bool>(value: false)
    var editCountRelay = BehaviorRelay<Int?>(value: nil)
    
    var editViewIsHiddenDrvier: Driver<Bool>
    var editViewSelectDriver: Driver<Bool>
    var editCountLabelTextDriver: Driver<String>
    var imageUrlString: String
    
    init(editMode: BehaviorRelay<EditMode>, product: Model.TattooThumbnail) {
        self.editMode = editMode
        self.imageUrlString = product.imageUrlString
        editViewIsHiddenDrvier = editMode
            .map { $0 == .normal }
            .asDriver(onErrorJustReturn: false)
        
        editViewSelectDriver = isSelectEditViewRelay
            .asDriver(onErrorJustReturn: false)
        
        editCountLabelTextDriver = editCountRelay
            .compactMap { "\($0)" }
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
        
        viewModel.editViewSelectDriver
            .drive(with: self) { owner, isSelected in
                owner.editView.backgroundColor = isSelected ? .green : .red
            }.disposed(by: disposeBag)
        
        viewModel.editCountLabelTextDriver
            .drive(tempLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.editViewSelectDriver
            .drive(with: self) { owner, isSelected in
                owner.editView.backgroundColor = isSelected ? .red : .blue
                owner.tempLabel.isHidden = !isSelected
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Initializer
    override func initialize() {
        self.setUI()
    }
    
    // MARK: - Life Cycle
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    // MARK: - UIComponents
    lazy var productImageView: UIImageView = {
        $0.layer.backgroundColor = UIColor.gray.cgColor
        return $0
    }(UIImageView())
    
    let editView = UIView()
    let tempLabel = UILabel()
    func setUI() {
        tempLabel.text = ""
        tempLabel.backgroundColor = .blue
        editView.backgroundColor = .orange
        contentView.backgroundColor = .green
        contentView.addSubview(productImageView)
        contentView.addSubview(editView)
        
        productImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        editView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        editView.addSubview(tempLabel)
        
        tempLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
    }
}
