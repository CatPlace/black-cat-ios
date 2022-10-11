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
        backgroundColor = .systemBackground
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    let headerLabel: UILabel = {
        let l = UILabel()
        l.text = "지난 이야기"
        l.font = .boldSystemFont(ofSize: 20)
        return l
    }()
}

extension LastMagazineHeaderView {
    func setUI() {
        addSubview(headerLabel)
        
        headerLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(20)
        }
    }
}
