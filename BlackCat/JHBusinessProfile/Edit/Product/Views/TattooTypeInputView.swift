//
//  TattooTypeInputView.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import BlackCatSDK

class TattooTypeInputView: UIView {
    enum Reusable {
        static let tattooTypeCell = ReusableCell<FilterCell>()
    }
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Binding
    func bind(to viewModel: TattooTypeInputViewModel) {
        collectionView.rx.itemSelected
            .map { TattooType.allCases[$0.row] }
            .bind(to: viewModel.tattooTypeRelay)
            .disposed(by: disposeBag)
        
        viewModel.cellViewModelsDriver
            .drive(collectionView.rx.items) { cv, row, data in
                let cell = cv.dequeue(Reusable.tattooTypeCell.self, for: IndexPath(row: row, section: 0))
                
                cell.viewModel = data
                return cell
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Initializer
    init(viewModel: TattooTypeInputViewModel) {
        super.init(frame: .zero)
        setUI()
        bind(to: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    let titleLabel: UILabel = {
        $0.text = "타입"
        $0.textColor = .init(hex: "#666666FF")
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
        return $0
    }(UILabel())
    
    var layout: UICollectionViewFlowLayout = {
        let width: CGFloat = UIScreen.main.bounds.width * 100/375
        let height: CGFloat = width * 0.4
        $0.itemSize = .init(width: width, height: height)
        return $0
    }(UICollectionViewFlowLayout())
    
    lazy var collectionView: UICollectionView = {
        $0.isScrollEnabled = false
        $0.register(Reusable.tattooTypeCell.self)
        $0.backgroundColor = .clear
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: layout))
    
    func setUI() {
        [titleLabel, collectionView].forEach { addSubview($0) }
        titleLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }
        collectionView.snp.makeConstraints {
            $0.height.equalTo(UIScreen.main.bounds.width * 100/375 * 0.4).priority(.high)
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width * 100/375 * 2 + 10)
            $0.centerX.equalToSuperview()
        }
    }
}
