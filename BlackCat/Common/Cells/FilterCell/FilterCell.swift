//
//  FilterCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/15.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

final class FilterCell: FilterBaseCell {
    
    // MARK: - Properties
    var viewModel: FilterCellViewModel? {
        didSet {
            guard let viewModel else { return }
            
            viewModel.typeStringDriver
                .drive(with: self) { owner, text in
                    owner.titleLabel.text = text
                }.disposed(by: self.disposeBag)
            
            viewModel.isSubscribeDriver
                .drive(with: self) { owner, isSubscribe in
                    owner.configureAttributes(color: viewModel.color, owner.titleLabel, isSubscribe)
                }.disposed(by: self.disposeBag)
        }
    }
    
    override func initialize() {
        setUI()
    }
    
    private func setUI() {
        contentView.layer.cornerRadius = 12
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - UIComponents
    private lazy var titleLabel: UILabel = {
        $0.textAlignment = .center
        $0.font = .appleSDGoithcFont(size: 16, style: .bold)
        return $0
    }(UILabel())
}
