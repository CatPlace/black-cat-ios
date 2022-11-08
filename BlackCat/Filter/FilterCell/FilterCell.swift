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
                    owner.configureAttributes(isSubscribe)
                }.disposed(by: self.disposeBag)
        }
    }

    func configureAttributes(_ isSubscribe: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.titleLabel.textColor = isSubscribe
            ? .white
            : .darkGray
            
            self?.contentView.backgroundColor = isSubscribe
            ? #colorLiteral(red: 0.4449512362, green: 0.1262507141, blue: 0.628126204, alpha: 1)
            : .systemGray6
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
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        return $0
    }(UILabel())
}

// MARK: - FilterCellViewModel

final class FilterCellViewModel {
    let typeStringDriver: Driver<String>
    let isSubscribeDriver: Driver<Bool>

    init(typeString: String, isSubscribe: Bool) {
        typeStringDriver = Observable.just(typeString)
            .map { $0 }
            .asDriver(onErrorJustReturn: "")
        
        isSubscribeDriver = Observable.just(isSubscribe)
            .asDriver(onErrorJustReturn: false)
    }
}
