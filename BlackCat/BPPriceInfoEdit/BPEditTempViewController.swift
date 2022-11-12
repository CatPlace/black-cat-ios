//
//  BPEditTempViewController.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/05.
//

import UIKit
import SnapKit
import RxSwift

class BPEditTempViewController: UIViewController {
    var disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(button)
        button.setTitle("넘어가요 에딧하러", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        button.rx.tap
            .bind {
                let vc = UINavigationController(rootViewController: BPPriceInfoEditViewController(reactor: BPPriceInfoEditReactor()))
                vc.modalPresentationStyle = .fullScreen
//                vc.setToolbarHidden(false, animated: true)
                self.present(vc, animated: true)
            }.disposed(by: disposeBag)
    }
    
    let button = UIButton()
}
