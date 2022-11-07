//
//  BPPriceInfoEditImageCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/06.
//

import UIKit
import ReactorKit

final class BPPriceInfoEditImageCell: BaseTableViewCell, View {
    typealias Reactor = BPPriceInfoEditImageCellReactor
    
    var disposeBag = DisposeBag()
    
    func bind(reactor: Reactor) {
        
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

final class BPPriceInfoEditImageCellReactor: Reactor {
    typealias Action = NoAction
    
    var initialState: BPPriceInfoEditModel
    
    init(initialState: BPPriceInfoEditModel) {
        self.initialState = initialState
    }
}
