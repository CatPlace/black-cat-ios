//
//  BPBaseCollectionReusableView.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/31.
//

import UIKit
import RxSwift

class BPBaseCollectionReusableView: UICollectionReusableView {
    var disposeBag: DisposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initalize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initalize() { /* overrider point */ }
}
