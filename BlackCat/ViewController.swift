//
//  ViewController.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/03.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let aview = UIView()
//    let btn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(aview)
        aview.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
//        aview.addSubview(btn)
//        btn.backgroundColor = .blue
//        btn.snp.makeConstraints {
//            $0.leading.trailing.equalToSuperview()
//            $0.height.equalTo(40)
//        }
        
//        btn.rx.tap
//            .bind {
//                let vc = MagazineDetailViewController(reactor: MagazineDetailViewController.Reactor())
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
    }
    
}
