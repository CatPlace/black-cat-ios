//
//  BPReviewCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import UIKit

// 🐻‍❄️ NOTE: - 다른 개발자님이 feature 이어 받으시도록 스타일로 맞춤.
final class BPReviewCell: BPBaseCollectionViewCell {
    
    func configureCell(with item: BPReviewModel) {
        loadImageUsingNuke(sender: ratingImageView, urlString: item.thumbnailImageUrlString)
        // 🐻‍❄️ NOTE: - 별점 이미지 디자이너님한테 요청
        reviewTitleLabel.text = item.reviewTitle
        reviewDescriptionLabel.text = item.reviewDescription
    }
    
    func setUI() {
        contentView.layer.cornerRadius = 15
        contentView.backgroundColor = .white
        
        addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints {
            $0.width.height.equalTo(80)
            $0.top.leading.equalToSuperview().inset(10)
        }
        
        addSubview(ratingImageView)
        ratingImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.trailing.equalToSuperview().inset(15)
            $0.width.equalTo(80)
            $0.height.equalTo(13)
        }
        
        addSubview(reviewTitleLabel)
        reviewTitleLabel.snp.makeConstraints {
            $0.top.equalTo(thumbnailImageView.snp.top)
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(10)
            $0.trailing.equalTo(ratingImageView.snp.leading)
        }
        
        addSubview(reviewDescriptionLabel)
        reviewDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(reviewTitleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(15)
        }
    }
    
    override func initialize() {
        self.setUI()
    }
    
    lazy var thumbnailImageView: UIImageView = {
        $0.layer.cornerRadius = 18
        $0.backgroundColor = UIColor(red: 0.851, green: 0.851, blue: 0.851, alpha: 1)
        
        return $0
    }(UIImageView())
    
    // 🐻‍❄️ NOTE: - https://github.com/evgenyneu/Cosmos
    // NOTE: - (기획 요구사항0 이미지로 처리하기로.)
    lazy var ratingImageView = UIImageView()
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
    
}
