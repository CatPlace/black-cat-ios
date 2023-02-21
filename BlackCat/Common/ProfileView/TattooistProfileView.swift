//
//  TattooistProfileView.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/02/21.
//

import UIKit

final class TattooistProfileView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let tattooProfileImageView: UIImageView = {
        $0.layer.cornerRadius = 15
        $0.clipsToBounds = true
        $0.backgroundColor = .lightGray
        return $0
    }(UIImageView())

    let tattooistNameLabel: UILabel = {
        $0.font = .systemFont(ofSize: 16)
        $0.tintColor = .black
        $0.text = ""
        return $0
    }(UILabel())
    
    let reportImageView: UIImageView = {
        $0.image = .init(named: "report")
        return $0
    }(UIImageView())
    
    func setUI() {
        [tattooProfileImageView, tattooistNameLabel, reportImageView].forEach { addSubview($0) }
        
        tattooProfileImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.width.height.equalTo(30)
            $0.bottom.equalToSuperview()
        }

        tattooistNameLabel.snp.makeConstraints {
            $0.leading.equalTo(tattooProfileImageView.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }
        
        reportImageView.snp.makeConstraints {
            $0.leading.equalTo(tattooistNameLabel.snp.trailing).offset(5)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.height.equalTo(12)
        }
    }
}
