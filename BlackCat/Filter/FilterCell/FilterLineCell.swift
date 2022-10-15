//
//  FilterLineCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/15.
//

import UIKit
import RxSwift
import SnapKit
import RxCocoa

final class FilterLineCell: FilterBaseCell {
    
    // MARK: - Initialize
    override func initialize() {
        setUI()
    }
    
    // MARK: - Properties
    private lazy var lineView = UIView()
}

extension FilterLineCell {
    func setUI() {
        contentView.addSubview(lineView)
        
        lineView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
