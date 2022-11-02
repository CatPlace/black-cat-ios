//
//  BPReviewCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import UIKit

// 🐻‍❄️ NOTE: - 다른 개발자님이 feature 이어 받으시도록 스타일로 맞춤.
final class BPReviewCell: BPBaseCell {
    
    func configureCell(with item: BPReviewModel) {
        
    }
    
    func setUI() {
        addSubview(thumbnailImageView)
        
        thumbnailImageView.snp.makeConstraints {
            $0.width.height.equalTo(80)
            $0.top.leading.equalToSuperview().inset(10)
        }
        
        addSubview(reviewTitleLabel)
        reviewTitleLabel.snp.makeConstraints {
            $0.top.equalTo(thumbnailImageView.snp.top)
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(10)
        }
        
        addSubview(reviewDescriptionLabel)
        reviewDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(thumbnailImageView.snp.bottom).offset(10)
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(15)
        }
        
        // MARK: - Rating Slider
        //addSubview(<#T##view: UIView##UIView#>)
    }
    
    override func initialize() {
        self.setUI()
    }
    
    lazy var thumbnailImageView: UIImageView = {
        $0.layer.cornerRadius = 18
        $0.backgroundColor = .gray
        
        return $0
    }(UIImageView())
    
    lazy var reviewTitleLabel: UILabel = {
        $0.textColor = .black
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
        
        return $0
    }(UILabel())
    
    lazy var reviewDescriptionLabel: UILabel = {
        $0.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        $0.numberOfLines = 2
        
        return $0
    }(UILabel())
    
    // 🐻‍❄️ NOTE: - https://github.com/evgenyneu/Cosmos
    lazy var ratringSiler = UISlider()
}
