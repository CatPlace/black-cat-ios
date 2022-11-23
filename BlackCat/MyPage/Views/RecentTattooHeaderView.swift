//
//  RecentTattooHeaderView.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

struct RecentTattooHeaderViewModel {
    
    let textDriver: Driver<String>
    let backgroundColorDriver: Driver<UIColor>

    init(text: String, backgroundColor: UIColor) {
        textDriver = .just(text)
        backgroundColorDriver = .just(backgroundColor)
    }
}

class RecentTattooHeaderView: UICollectionReusableView {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Binding
    func bind(to viewModel: RecentTattooHeaderViewModel) {
        viewModel.textDriver
            .drive(headerLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.backgroundColorDriver
            .drive(rx.backgroundColor)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    let headerLabel: UILabel = {
        let l = UILabel()
        l.font = .boldSystemFont(ofSize: 20)
        return l
    }()
}

extension RecentTattooHeaderView {
    func setUI() {
        addSubview(headerLabel)
        
        headerLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(20)
        }
    }
}
