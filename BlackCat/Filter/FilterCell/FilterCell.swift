//
//  FilterCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/15.
//

import UIKit
import RxSwift
import RxCocoa

final class FilterCell: FilterBaseCell {
    typealias ViewModel = FilterCellViewModel
    
    // MARK: - Properties
    var viewModel: ViewModel? {
        didSet {
            guard let viewModel else { return }
            bind(viewModel)
        }
    }

    // MARK: - Binding
    func bind(_ viewModel: ViewModel) {
        viewModel.itemDriver
            .asObservable()
            .withUnretained(self)
            .bind { owner, item in
                owner.setUI()
                owner.titleLabel.text = item
            }.disposed(by: self.disposeBag)
    }
    
    private func setUI() {
        contentView.addSubview(titleLabel)
        contentView.layer.cornerRadius = 16
        contentView.backgroundColor = .gray
        
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        return $0
    }(UILabel())
}

class FilterCellViewModel {
    let itemDriver: Driver<String>
    
    init(item: String) {
        itemDriver = Observable.just(item)
            .asDriver(onErrorJustReturn: "🚨 버그 신고를 해주새요.")
    }
}
