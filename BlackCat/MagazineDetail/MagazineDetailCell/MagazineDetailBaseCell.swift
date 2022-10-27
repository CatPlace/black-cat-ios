//
//  MagazineBaseCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/06.
//

import UIKit
import RxSwift

class MagazineDetailBaseCell: BaseTableViewCell {
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - textBuilder
    func contentTextLabelBuilder(_ sender: UILabel, _ item: MagazineDetailModel) {
        sender.numberOfLines = 0
        sender.lineBreakMode = .byWordWrapping
        
        sender.textColor = item.textColor.toUIColor()
        sender.text = item.text
        sender.textAlignment = item.textAlignment.toNSTextAlignment()
        sender.font = .systemFont(ofSize: CGFloat(item.fontSize),
                                  weight: item.fontWeight.toFontWeight())
    }
    
    // MARK: - imageBuilder
    func contentImageViewBuilder(_ sender: UIImageView, _ item: MagazineDetailModel) {
        if let imageUrlString = item.imageUrlString { sender.image = UIImage(named: imageUrlString) }
        
        sender.layer.cornerRadius = CGFloat(item.imageCornerRadius)
        sender.clipsToBounds = true
    }
}
