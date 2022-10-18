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
import RealmSwift

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
            .bind { [weak self] _ in
                let vc = FilterViewController(reactor: FilterReactor())
                vc.preferredSheetSizing = .fit
                self?.present(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        print("🍑 \(Realm.Configuration.defaultConfiguration.fileURL)")
    }
    
    let button = UIButton()
    let disposeBag = DisposeBag()
}
