//
//  UpgradeBusinessViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/10.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import BlackCatSDK
class UpgradeBusinessViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    func bind() {
        upgradeButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = ProfileViewController(
                    viewModel: .init(nameInputViewModel: .init(title: "이름"),
                                     emailInputViewModel: .init(title: "이메일"),
                                     phoneNumberInputViewModel: .init(title: "전화번호"),
                                     genderInputViewModel: .init(),
                                     areaInputViewModel: .init(),
                                     type: .upgrade))
                
                owner.present(vc, animated: false)
            }.disposed(by: disposeBag)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print(navigationController?.viewControllers)
        navigationController?.navigationBar.backgroundColor = .red

        
        view.backgroundColor = .orange
    }
    
    let upgradeButton: UIButton = {
        $0.setTitle("계정 업그레이드", for: .normal)
        $0.backgroundColor = .white
        $0.setTitleColor(.purple, for: .normal)
        return $0
    }(UIButton())
    
    func setUI() {
        view.addSubview(upgradeButton)
        upgradeButton.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
}
