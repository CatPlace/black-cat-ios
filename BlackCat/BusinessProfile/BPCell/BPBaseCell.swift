//
//  BPBaseCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import UIKit
import RxSwift
import Nuke

class BPBaseCell: BaseCollectionViewCell {
    var disposeBag = DisposeBag()
    
    func loadImageUsingNuke(sender: UIImageView, urlString: String) {
        // 🐻‍❄️ NOTE: - NUKE 디폴트 이미지 세팅 가능한데, 공식문서에 어제는 보였던 것 같은데, 오늘은 아무리 찾아도 안보여서,, 우선 패스,,
        
        let options = ImageLoadingOptions(failureImageTransition: .fadeIn(duration: 0.5))
        guard let url = URL(string: urlString) else { return }
        
        Nuke.loadImage(with: url,
                       options: options,
                       into: sender)
    }
}
