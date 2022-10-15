//
//  FilterTitleCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/15.
//

import UIKit
import RxSwift
import SnapKit
import RxCocoa

final class FilterTitleCell: FilterBaseCell {
    
    // MARK: - Initilalize
    override func initialize() {
        print("did CALL INIT")
        setUI()
    }
    
    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        $0.text = "필터 검색"
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 28, weight: .semibold)
        return $0
    }(UILabel())
}

extension FilterTitleCell {
    func setUI() {
        [titleLabel].forEach { contentView.addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualTo(contentView.safeAreaLayoutGuide)
        }
        titleLabel.backgroundColor = .red
        contentView.backgroundColor = .orange

    }
}
