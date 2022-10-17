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
    
    enum Status: Int {
        case subscribe = 0
        case unSubscribe = 1
    }
    
    // MARK: - Properties
    var taskViewModel: TaskVM? {
        didSet {
            guard let taskViewModel else { return }
            
            taskViewModel.typeStringDriver
                .drive(with: self) { owner, text in
                    owner.titleLabel.text = text
                }.disposed(by: self.disposeBag)
            
            taskViewModel.isSubscribeDriver
                .asObservable()
                .bind { [weak self] value in
                    self?.configureAttributes(value)
                }
                .disposed(by: self.disposeBag)
        }
    }
    
    var loactionViewModel: LoactionVM? {
        didSet {
            guard let loactionViewModel else { return }
            
            loactionViewModel.itemDriver
                .map { $0.type.rawValue }
                .drive { self.titleLabel.text = $0 }
                .disposed(by: self.disposeBag)
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
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

extension FilterCell.Status {
    var backgroundColor: UIColor? {
        switch self {
        case .subscribe: return .darkGray
        case .unSubscribe: return #colorLiteral(red: 0.4449512362, green: 0.1262507141, blue: 0.628126204, alpha: 1)
        }
    }
    
    var textColor: UIColor? {
        switch self {
        case .subscribe: return .white
        case .unSubscribe: return .gray
        }
    }
}

// MARK: - FilterCellTaskViewModel

final class FilterCellTaskViewModel {
    let typeStringDriver: Driver<String>
    let isSubscribeDriver: Driver<Bool>
    
    init(item: FilterTask) {
        
        typeStringDriver = Observable.just(item.type)
            .map { $0.rawValue }
            .asDriver(onErrorJustReturn: "")
        
        isSubscribeDriver = Observable.just(item.isSubscribe)
            .asDriver(onErrorJustReturn: false)
    }
}

// MARK: - FilterCellLocationViewModel

final class FilterCellLocationViewModel {
    let itemDriver: Driver<FilterLocation>

    init(item: FilterLocation) {
        itemDriver = Observable.just(item)
            .asDriver(onErrorJustReturn: .init(item: .서울))
    }
}
