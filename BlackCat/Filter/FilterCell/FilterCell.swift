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
    
    enum Status {
        case subscribe
        case unSubscribe
    }
    
    // MARK: - Properties
    var taskViewModel: TaskVM? {
        didSet {
            guard let taskViewModel else { return }
            setUI()
            
            taskViewModel.itemDriver
                .map { $0.type.rawValue }
                .drive { self.titleLabel.text = $0 }
                .disposed(by: self.disposeBag)
        }
    }
    
    var loactionViewModel: LoactionVM? {
        didSet {
            guard let loactionViewModel else { return }
            setUI()
            
            loactionViewModel.itemDriver
                .map { $0.type.rawValue }
                .drive { self.titleLabel.text = $0 }
                .disposed(by: self.disposeBag)
        }
    }
    
    func selectedAttributes() {
        DispatchQueue.main.async { [weak self] in
            self?.titleLabel.textColor = .systemGray
//            self?.contentView.backgroundColor = self?.viewModel?.status.selectedBackgroundColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setUI() {
        contentView.layer.cornerRadius = 12
        contentView.backgroundColor = .gray
        contentView.addSubview(titleLabel)
        
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
