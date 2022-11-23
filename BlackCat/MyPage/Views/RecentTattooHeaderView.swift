//
//  RecentTattooHeaderView.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/24.
//

import UIKit

struct RecentTattooHeaderViewModel {
    
    init(text: String) {
        
    }
}

class RecentTattooHeaderView: UICollectionReusableView {
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    let headerLabel: UILabel = {
        let l = UILabel()
        l.text = "최근 본 타투"
        l.font = .boldSystemFont(ofSize: 20)
        return l
    }()
}

extension RecentTattooHeaderView {
    func setUI() {
        addSubview(headerLabel)
        
        headerLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(20)
        }
    }
}
