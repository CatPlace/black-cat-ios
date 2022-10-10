//
//  RecentMagazineFooterView.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/09.
//

import UIKit

import RxSwift
import RxCocoa
import RxRelay

struct RecentMagazineFooterViewModel {
    
    let currentPageRelay = BehaviorRelay<Int>(value: 0)
    let numberOfPagesRelay = BehaviorRelay<Int>(value: 4)
    
    let currentPageDriver: Driver<Int>
    let numberOfPagesDriver: Driver<Int>
    
    init() {
        currentPageDriver = currentPageRelay.asDriver()
        numberOfPagesDriver = numberOfPagesRelay.asDriver(onErrorJustReturn: 0)
    }
}

class RecentMagazineFooterView: UICollectionReusableView {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: RecentMagazineFooterViewModel = RecentMagazineFooterViewModel()
    
    // MARK: - Binding
    func bind() {
        viewModel.currentPageDriver
            .drive(onNext: { [weak self] page in
                self?.pageControl.set(progress: page, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.numberOfPagesDriver
            .drive(pageControl.rx.numberOfPages)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    //MARK: UIComponents
    let pageControl: JHPageControl = {
        let pc = JHPageControl()
        pc.tintColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1)
        pc.currentPageTintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        pc.progress = 0
        pc.radius = 3
        pc.elementWidth = 30
        return pc
    }()
    
    func setUI() {
        addSubview(pageControl)
        
        pageControl.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}
