//
//  BPProfileCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/03.
//

import UIKit

// 🐻‍❄️ NOTE: - 다른 개발자님이 feature 이어 받으시도록 스타일로 맞춤.
final class BPProfileCell: BPBaseCollectionViewCell {
    
    func configureCell(with description: String) {
        profileTitleLabel.text = "자기소개"
        profileDescriptionLabel.backgroundColor = .white
        profileDescriptionLabel.text = description + "AASDASKLDGJSLKGJLSJGLJDSKJLJSDJFLSDKFJSDKFJLSDJFKSDFLSDJKFJLSDJFLKDSJKFJSDLFKSDFJLSDJFKLDSJFLJSDFJSLDJFL\nSDJFKLSJLFJSDKLFJLSKDJFLSDKJFLDJSFKJSDLFJDKSJFKLSDJFLKJDSLKFJSDKFJSLDJFLDSJKFJSDKLJFKSKDLFJJDSFJSDKJFLSDJFKSJLFKJDLFJKDJSLFJDSKJFLKSDJFLJSDKFJSDLKFJLSDKJF"
    }

    func setUI() {
        
        contentView.addSubview(profileTitleLabel)
        profileTitleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(30)
        }
        
        contentView.addSubview(profileDescriptionLabel)
        profileDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(profileTitleLabel.snp.bottom).offset(10)
            $0.height.greaterThanOrEqualTo(500)
            $0.leading.trailing.equalTo(profileTitleLabel)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
    
    override func initialize() {
        self.setUI()
    }
    
    lazy var profileTitleLabel: UILabel = {
        $0.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
        $0.numberOfLines = 1
        
        return $0
    }(UILabel())
    
    lazy var profileDescriptionLabel: VerticalAlignLabel = {
        $0.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        return $0
    }(VerticalAlignLabel())
}

public class VerticalAlignLabel: UILabel {
    enum VerticalAlignment {
        case top
        case middle
        case bottom
    }

    var verticalAlignment : VerticalAlignment = .top {
        didSet {
            setNeedsDisplay()
        }
    }

    override public func textRect(forBounds bounds: CGRect, limitedToNumberOfLines: Int) -> CGRect {
        let rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: limitedToNumberOfLines)

        if UIView.userInterfaceLayoutDirection(for: .unspecified) == .rightToLeft {
            switch verticalAlignment {
            case .top:
                return CGRect(x: self.bounds.size.width - rect.size.width, y: bounds.origin.y, width: rect.size.width, height: rect.size.height)
            case .middle:
                return CGRect(x: self.bounds.size.width - rect.size.width, y: bounds.origin.y + (bounds.size.height - rect.size.height) / 2, width: rect.size.width, height: rect.size.height)
            case .bottom:
                return CGRect(x: self.bounds.size.width - rect.size.width, y: bounds.origin.y + (bounds.size.height - rect.size.height), width: rect.size.width, height: rect.size.height)
            }
        } else {
            switch verticalAlignment {
            case .top:
                return CGRect(x: bounds.origin.x, y: bounds.origin.y, width: rect.size.width, height: rect.size.height)
            case .middle:
                return CGRect(x: bounds.origin.x, y: bounds.origin.y + (bounds.size.height - rect.size.height) / 2, width: rect.size.width, height: rect.size.height)
            case .bottom:
                return CGRect(x: bounds.origin.x, y: bounds.origin.y + (bounds.size.height - rect.size.height), width: rect.size.width, height: rect.size.height)
            }
        }
    }

    override public func drawText(in rect: CGRect) {
        let r = self.textRect(forBounds: rect, limitedToNumberOfLines: self.numberOfLines)
        super.drawText(in: r)
    }
}
