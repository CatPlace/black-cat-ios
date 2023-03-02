//
//  BPProfileCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/03.
//

import UIKit

// 🐻‍❄️ NOTE: - 다른 개발자님이 feature 이어 받으시도록 스타일로 맞춤.

// TODO: -
final class BPProfileCellViewModel {
    let tattooistProfileImageUrlString: String
    let tattooistName: String?
    let address: String?
    let description: String?
    
    init(
        tattooistProfileImageUrlString: String,
        tattooistName: String?,
        address: String?,
        description: String?
    ) {
        self.tattooistProfileImageUrlString = tattooistProfileImageUrlString
        self.tattooistName = tattooistName
        self.address = address
        self.description = description
    }
}

final class BPProfileCell: BPBaseCollectionViewCell {
    override func initialize() {
        self.setUI()
    }
    
    let profileView = TattooistProfileView()
    let addressLabel: UILabel = {
        $0.text = "주소"
        $0.font = .appleSDGoithcFont(size: 14, style: .regular)
        return $0
    }(UILabel())
    let HLine: UIView = {
        $0.backgroundColor = .init(hex: "#666666FF")
        return $0
    }(UIView())
    private let profileTitleLabel: UILabel = {
        $0.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
        return $0
    }(UILabel())
    
    private let profileDescriptionLabel: VerticalAlignLabel = {
        $0.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        $0.font = .appleSDGoithcFont(size: 16, style: .medium)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        return $0
    }(VerticalAlignLabel())
    
    func configureCell(with viewModel: BPProfileCellViewModel) {
        loadImageUsingNuke(sender: profileView.tattooProfileImageView, urlString: viewModel.tattooistProfileImageUrlString)
        profileView.tattooistNameLabel.text = viewModel.tattooistName
        addressLabel.text = viewModel.address
        profileTitleLabel.text = "자기소개"
        profileDescriptionLabel.text = viewModel.description
    }
    
    func setUI() {
        [profileView, addressLabel, HLine, profileTitleLabel, profileDescriptionLabel].forEach { contentView.addSubview($0) }
        
        profileView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(30)
        }
        
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(15)
            $0.leading.equalTo(profileView)
        }
        
        HLine.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        profileTitleLabel.snp.makeConstraints {
            $0.top.equalTo(HLine).inset(30)
            $0.leading.trailing.equalToSuperview().inset(30)
        }
        
        profileDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(profileTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(profileTitleLabel)
            $0.bottom.equalToSuperview().inset(20)
        }
        
    }
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
