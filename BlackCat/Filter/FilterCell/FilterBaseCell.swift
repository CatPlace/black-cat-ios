//
//  FilterBaseCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/15.
//

import UIKit
import RxSwift

// MARK: - Cell
class FilterBaseCell: UITableViewCell {
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Initializing
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialize() { /* override point */ }
}
