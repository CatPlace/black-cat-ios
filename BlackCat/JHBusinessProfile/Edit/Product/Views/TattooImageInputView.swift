//
//  TattooInputView.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/18.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa
import BlackCatSDK

class TattooImageInputView: UIView {
    
    enum Reusable {
        static let tattooImageInputCell = ReusableCell<TattooImageInputCell>()
    }
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: TattooImageInputViewModel
    let cellWidth: CGFloat = (UIScreen.main.bounds.width - 46) / 5
    
    // MARK: - Binding
    func bind(to viewModel: TattooImageInputViewModel) {
        viewModel.cellViewModelsDrvier
            .drive(collectionView.rx.items) { cv, row, viewModel in
                let cell = cv.dequeue(Reusable.tattooImageInputCell, for: IndexPath(row: row, section: 0))
                cell.configureCell(with: viewModel)
                
                return cell
            }.disposed(by: disposeBag)
        
        viewModel.countLimitLabelTextDriver
            .drive(limitLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Initializer
    init(viewModel: TattooImageInputViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        bind(to: viewModel)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    let titleLabel: UILabel = {
        $0.text = "사진"
        $0.textColor = .init(hex: "#666666FF")
        $0.font = .appleSDGoithcFont(size: 16, style: .bold)
        return $0
    }(UILabel())
    
    let limitLabel: UILabel = {
        let l = UILabel()
        $0.textColor = .init(hex: "#999999FF")
        $0.font = .appleSDGoithcFont(size: 12, style: .regular)
        return $0
    }(UILabel())
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = .init(width: cellWidth, height: cellWidth)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 1
        layout.sectionInset = .init(top: 1, left: 1, bottom: 1, right: 1)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.isScrollEnabled = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(Reusable.tattooImageInputCell)

        return cv
    }()
    
    func setUI() {
        [titleLabel, limitLabel, collectionView].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
        }
        
        limitLabel.snp.makeConstraints {
            $0.bottom.equalTo(titleLabel.snp.bottom).offset(6)
            $0.trailing.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(cellWidth + 2.1)
            $0.bottom.equalToSuperview()
        }
    }
}

