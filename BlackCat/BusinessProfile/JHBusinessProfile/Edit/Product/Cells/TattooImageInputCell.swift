//
//  TattooImageInputCell.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/21.
//

import UIKit

class TattooImageInputCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .white
        setUI()
    }
    
    func configureCell(with imageData: Data?) {
        controlImageView.image = UIImage(named: "addIcon")
        if let imageData {
            imageView.image = UIImage(data: imageData)
            contentView.backgroundColor = .black.withAlphaComponent(0.5)
            controlImageView.transform = controlImageView.transform.rotated(by: .pi/4)
        } else {
            imageView.backgroundColor = .init(hex: "#D9D9D9FF")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func prepareForReuse() {
        imageView.image = nil
        contentView.backgroundColor = .clear
        controlImageView.transform = CGAffineTransformIdentity
    }
    
    let imageView = UIImageView()
    let controlImageView = UIImageView()
    
    func setUI() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.addSubview(controlImageView)
        
        controlImageView.snp.makeConstraints {
            $0.width.height.equalTo(Constant.width * 22)
            $0.center.equalToSuperview()
        }
    }
}
