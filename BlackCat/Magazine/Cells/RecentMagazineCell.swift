//
//  MagazineFamouseCell.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/05.
//

import UIKit

import RxSwift
import RxCocoa
import RxRelay
import SnapKit
import Nuke

struct RecentMagazineCellViewModel {
    let magazine: Magazine
    
    //output
    let imageUrlDriver: Driver<String>
    
    init(magazine: Magazine) {
        self.magazine = magazine
        
        imageUrlDriver = Observable
            .just(magazine.imageUrl)
            .asDriver(onErrorJustReturn: "")
    }
}

class RecentMagazineCell: UICollectionViewCell {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: RecentMagazineCellViewModel? {
        didSet {
            guard let viewModel else { return }
            bind(to: viewModel)
        }
    }
    
    // MARK: - Binding
    func bind(to viewModel: RecentMagazineCellViewModel) {
        viewModel.imageUrlDriver
            .compactMap { URL(string: $0) }
            .drive(onNext: {
                Nuke.loadImage(with: $0, into: self.recentMagazineImageView)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }

    let recentMagazineImageView = UIImageView()
}

extension RecentMagazineCell {
    func setUI() {
        addSubview(recentMagazineImageView)
        recentMagazineImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
