//
//  CollectionReusableView.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/09.
//

import UIKit

class LastMagazineHeaderView: UICollectionReusableView {
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    let headerLabel = UILabel()
}

extension LastMagazineHeaderView {
    func setUI() {
        backgroundColor = .systemBackground
        
        addSubview(headerLabel)
        
        headerLabel.text = "지난 이야기"
        headerLabel.font = .boldSystemFont(ofSize: 20)
        
        headerLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(20)
        }
    }
}
