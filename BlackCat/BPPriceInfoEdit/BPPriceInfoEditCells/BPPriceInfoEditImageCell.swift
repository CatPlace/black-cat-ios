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
                .drive(editImageView.rx.image)
                .disposed(by: disposeBag)
            
        }
    }
    func setUI() {
        contentView.addSubview(editImageView)
        editImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func initialize() {
        self.setUI()
    }
    
    lazy var editImageView: UIImageView = {
        $0.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        return $0
    }(UIImageView())
}
