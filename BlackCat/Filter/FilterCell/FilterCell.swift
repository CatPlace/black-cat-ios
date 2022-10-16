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
    
    func bind(_ viewModel: ViewModel) {
        
    }
    
    // MARK: - Properties
    private lazy var titleLabel = UILabel()
}

class FilterCellViewModel {
    
}
