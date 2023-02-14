//
//  PriceInfoEditViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/06.
//

import UIKit
import RxSwift
import RxKeyboard
class PriceInfoEditViewModel {
    
}
class PriceInfoEditViewController: VerticalScrollableViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: PriceInfoEditViewModel
    
    // MARK: - Binding
    func bind(to viewModel: PriceInfoEditViewModel) {
        RxKeyboard.instance.visibleHeight
            .drive(with: self) { owner, keyboardVisibleHeight in
                owner.updateView(with: keyboardVisibleHeight)
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Initializer
    init(viewModel: PriceInfoEditViewModel = PriceInfoEditViewModel()) {
        self.viewModel = viewModel
        super.init()
        appendNavigationLeftBackButton()
        appendNavigationLeftLabel(title: "견적서 편집")
        setUI()
        bind(to: viewModel)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView(with height: CGFloat) {
        scrollView.snp.updateConstraints {
            $0.bottom.equalToSuperview().inset(height)
        }
        
        completeButton.snp.updateConstraints {
            $0.bottom.equalToSuperview().inset(
                height == 0
                ? 30
                : height + 15
            )
        }
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .init(hex: "#F4F4F4FF")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBackgroundColor(color: .init(hex: "#333333FF"))
    }
    
    // MARK: - UIComponents
    // TODO: - 편집 뷰 어떤식으로 ?
    let tempView = UIView()
    let completeButton: UIButton = {
        $0.setTitle("수정 완료", for: .normal)
        $0.titleLabel?.font = .appleSDGoithcFont(size: 24, style: .bold)
        $0.backgroundColor = .init(hex: "#333333FF")
        $0.layer.cornerRadius = 20
        return $0
    }(UIButton())
    
    func setUI() {
        
        contentView.addSubview(tempView)
        
        tempView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(700)
        }
        
        view.addSubview(completeButton)
        
        completeButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(30)
            $0.width.equalTo(Constant.width * 251)
            $0.height.equalTo(Constant.height * 60)
            $0.centerX.equalToSuperview()
        }
    }
}
