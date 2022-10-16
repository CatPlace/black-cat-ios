//
//  FilterExampleViewController.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/15.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class FilterExampleViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(button)
        button.setTitle("도라에몽 주머니", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        button.rx.tap
            .debug("didTapTouched")
            .bind { [weak self] _ in
                let vc = FilterViewController()
                vc.preferredSheetSizing = .fit
                self?.present(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    let button = UIButton()
    let disposeBag = DisposeBag()
}
