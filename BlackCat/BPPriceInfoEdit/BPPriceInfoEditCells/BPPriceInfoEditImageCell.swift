//
//  BPPriceInfoEditImageCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/06.
//

import UIKit
import ReactorKit

final class BPPriceInfoEditImageCell: BaseTableViewCell {
    var disposeBag = DisposeBag()
    var viewModel: BPPriceInfoEditCellViewModel? {
        didSet {
            guard let viewModel else { print("💀 guard에 걸렸네요,,"); return; }
            
            viewModel.imageDriver
                .distinctUntilChanged() // 이건 스트림 분기
                .drive(with: self) { owner, image in
                    owner.setUI(to: image)
                    
                    owner.editImageView.image = image
                }.disposed(by: disposeBag)
            
        }
    }
    
    private func setUI(to image: UIImage) {
        contentView.backgroundColor =  UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        
        contentView.addSubview(editImageView)
        editImageView.snp.makeConstraints {
            $0.width.equalTo(image.size.width)
            $0.height.equalTo(image.size.height)
            $0.centerX.equalToSuperview()
            $0.top.bottom.equalToSuperview().priority(.medium)
        }
    }
    
    override func initialize() { }
    
    lazy var editImageView: UIImageView = {
        $0.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        return $0
    }(UIImageView())
}
