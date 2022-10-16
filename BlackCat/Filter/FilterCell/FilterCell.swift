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
//    var viewModel: ViewModel? {
//        didSet {
//            print("didSetCALLED")
//            guard let viewModel else { return }
//            bind(viewModel)
//        }
//    }
//
//    func bind(_ viewModel: ViewModel) {
//        print("여기는 셀")
//        contentView.backgroundColor = .red
//    }
    
    func configureCell(with: String) {
        setUI()
        print("ddd")
        titleLabel.text = with
        contentView.backgroundColor = .green
    }
    
    func setUI() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Properties
    private lazy var titleLabel = UILabel()
}

class FilterCellViewModel {
    
}
