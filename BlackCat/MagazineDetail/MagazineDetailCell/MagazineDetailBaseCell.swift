//
//  MagazineBaseCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/06.
//

import UIKit
import RxSwift

class MagazineDetailBaseCell: UITableViewCell {
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Initializing
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialize() { /* override point */ }
    
    func contentTextLabelBuilder(_ sender: UILabel, _ item: MagazineDetailModel) {
        sender.textColor = item.textColor.toUIColor()
        sender.text = item.text
        sender.textAlignment = item.textAlignment.toNSTextAlignment()
        sender.font = .systemFont(ofSize: CGFloat(item.fontSize),
                                  weight: item.fontWeight.toFontWeight())
    }
}