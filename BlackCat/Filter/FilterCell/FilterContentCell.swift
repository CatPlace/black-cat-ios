//
//  FilterContentCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/15.
//

import UIKit
import RxSwift
import SnapKit
import RxCocoa

final class FilterContentCell: FilterBaseCell {
    
    // MARK: - Initialize
    override func initialize() {
        setUI()
    }
    
    // MARK: - Properties
    private var contentLabel: UILabel = {
        $0.textColor = .green
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
        return $0
    }(UILabel())
    private var contentCollectionView = UICollectionView()
}

extension FilterContentCell {
    func setUI() {
        [contentLabel, contentCollectionView].forEach { contentView.addSubview($0) }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(20)
        }
    }
}


