//
//  MyPageTattooCell.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import Nuke

class MyPageTattooCellViewModel {
    
    let imageUrlStringDriver: Driver<String>
    let titleDrvier: Driver<String>
    let userNameDriver: Driver<String>
    
    init(tattoo: Tattoo) {
        imageUrlStringDriver = .just(tattoo.imageUrl)
        titleDrvier = .just(tattoo.title)
        userNameDriver = .just(tattoo.userName)
    }
}

class MyPageTattooCell: MyPageBaseCell {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Binding
    func bind(to viewModel: MyPageTattooCellViewModel) {
        viewModel.imageUrlStringDriver
            .compactMap { URL(string: $0) }
            .drive(with: self) { owner, url in
                Nuke.loadImage(with: url, into: owner.tattooImageView)
            }.disposed(by: disposeBag)
        
        viewModel.titleDrvier
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.userNameDriver
            .drive(userNameLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Initializer
    override func initialize() {
        configureCell(cornerRadius: 24, y: 2, blur: 20)
        setUI()
    }
    
    // MARK: - Life Cycle
    
    // MARK: - UIComponents
    let VStackView: UIStackView = {
        let v = UIStackView()
        v.distribution = .equalSpacing
        v.axis = .vertical
        return v
    }()
    let tattooImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 16
        v.backgroundColor = .init(hex: "#D9D9D9FF")
        return v
    }()
    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .boldSystemFont(ofSize: 16)
        l.backgroundColor = .red
        return l
    }()
    let userNameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16)
        l.backgroundColor = .blue
        return l
    }()
    func setUI() {
        addSubview(VStackView)
        
        VStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        
        [tattooImageView, titleLabel, userNameLabel].forEach { VStackView.addArrangedSubview($0) }
        
        tattooImageView.snp.makeConstraints {
            $0.height.equalTo(frame.width - 20)
        }
    }
}
