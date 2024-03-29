//
//  UpgradeBusinessViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/10.
//

import UIKit
import RxSwift
import BlackCatSDK
import RxGesture

class UpgradeBusinessViewModel {
    
}

class UpgradeBusinessViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: UpgradeBusinessViewModel
    // MARK: - Binding
    func bind(to viewModel: UpgradeBusinessViewModel) {
        upgradeButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = ProfileViewController(viewModel: .init(type: .upgrade))
                
                owner.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Initializer
    init(viewModel: UpgradeBusinessViewModel = .init()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        bind(to: viewModel)
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBackgroundColor(color: .init(hex: "#7210A0FF"))
    }
    // MARK: - Function
    func configure() {
        view.backgroundColor = .white
        appendNavigationLeftBackButton()
        appendNavigationLeftLabel(title: "계정 업그레이드", color: .white)
    }
    
    // MARK: - UIComponents
    let firstUpgradeMentImageView: UIImageView = {
        $0.image = .init(named: "upgradeMent_1")
        return $0
    }(UIImageView())
    
    let secondUpgradeMentImageView: UIImageView = {
        $0.image = .init(named: "upgradeMent_2")
        return $0
    }(UIImageView())
    
    let thirdUpgradeMentImageView: UIImageView = {
        $0.image = .init(named: "upgradeMent_3")
        return $0
    }(UIImageView())

    let upgradeButton: UIButton = {
        $0.setTitle("구독 결제하기", for: .normal)
        $0.titleLabel?.font = .appleSDGoithcFont(size: 24, style: .bold)
        $0.backgroundColor = .init(hex: "#7210A0FF")
        $0.titleLabel?.textAlignment = .center
        return $0
    }(UIButton())
}

extension UpgradeBusinessViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUI() {
        view.addSubview(upgradeButton)
        [firstUpgradeMentImageView, secondUpgradeMentImageView, thirdUpgradeMentImageView].forEach { view.addSubview($0) }
        firstUpgradeMentImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(30)
            $0.centerX.equalToSuperview()
        }
        
        secondUpgradeMentImageView.snp.makeConstraints {
            $0.top.equalTo(firstUpgradeMentImageView.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
        }
        
        thirdUpgradeMentImageView.snp.makeConstraints {
            $0.top.equalTo(secondUpgradeMentImageView.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
        }

        upgradeButton.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(90)
        }
    }
}
