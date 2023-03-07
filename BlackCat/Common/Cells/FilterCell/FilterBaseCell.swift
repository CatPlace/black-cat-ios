//
//  FilterBaseCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/15.
//

import UIKit
import RxSwift

class FilterBaseCell: BaseCollectionViewCell {
    var disposeBag: DisposeBag = DisposeBag()
    
    func configureAttributes(color: UIColor?, _ sender: UILabel, _ isSubscribe: Bool) {
        sender.textColor = isSubscribe
        ? color
        : .darkGray
        
        self.contentView.backgroundColor = isSubscribe
        ? #colorLiteral(red: 0.4449512362, green: 0.1262507141, blue: 0.628126204, alpha: 1)
        : color
    }
}
