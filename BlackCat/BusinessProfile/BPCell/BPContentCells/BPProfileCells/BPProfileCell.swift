//
//  BPProfileCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/03.
//

import UIKit

// 🐻‍❄️ NOTE: - 다른 개발자님이 feature 이어 받으시도록 스타일로 맞춤.
final class BPProfileCell: BPBaseCell {
    
    func configureCell(with item: BPProfileModel) {
        profileTitleLabel.text = item.title
        profileDescriptionLabel.text = item.description
    }
    
    func setUI() {
        
        contentView.addSubview(profileTitleLabel)
        profileTitleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(30)
        }
        
        contentView.addSubview(profileDescriptionLabel)
        profileDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(profileTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(profileTitleLabel)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
    
    override func initialize() {
        print("called")
        self.setUI()
    }
    
    lazy var profileTitleLabel: UILabel = {
        $0.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
        $0.numberOfLines = 1
        
        return $0
    }(UILabel())
    
    lazy var profileDescriptionLabel: UILabel = {
        $0.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        
        return $0
    }(UILabel())
}
