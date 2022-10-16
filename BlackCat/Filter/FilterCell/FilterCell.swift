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
    typealias TaskVM = FilterCellTaskViewModel
    typealias LoactionVM = FilterCellLocationViewModel
    
    // MARK: - Properties
    var taskVM: TaskVM? {
        didSet {
            guard let taskVM else { return }
            setUI()
            
            taskVM.itemDriver
                .map { $0.type.rawValue }
                .drive { self.titleLabel.text = $0 }
                .disposed(by: self.disposeBag)
        }
    }
    
    var loactionVM: LoactionVM? {
        didSet {
            guard let loactionVM else { return }
            setUI()
            
            loactionVM.itemDriver
                .map { $0.type.rawValue }
                .drive { self.titleLabel.text = $0 }
                .disposed(by: self.disposeBag)
        }
    }
    
    private func setUI() {
        contentView.addSubview(titleLabel)
        contentView.layer.cornerRadius = 12
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

class FilterCellTaskViewModel {
    let itemDriver: Driver<FilterTask>
    
    init(item: FilterTask) {
        itemDriver = Observable.just(item)
            .asDriver(onErrorJustReturn: .init())
    }
}

class FilterCellLocationViewModel {
    let itemDriver: Driver<FilterLocation>

    init(item: FilterLocation) {
        itemDriver = Observable.just(item)
            .asDriver(onErrorJustReturn: .init(item: .서울))
    }
}
