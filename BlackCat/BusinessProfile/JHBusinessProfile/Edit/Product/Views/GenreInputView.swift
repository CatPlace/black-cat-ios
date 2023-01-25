//
//  GenreInputView.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/19.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import BlackCatSDK

class GenreInputView: UIView {
    enum Reusable {
        static let genreInputCell = ReusableCell<GenreInputCell>()
    }
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Binding
    func bind(to viewModel: GenreInputViewModel) {
        collectionView.rx.itemSelected
            .bind(to: viewModel.selectedIndexRelay)
            .disposed(by: disposeBag)
        
        viewModel.cellViewModelsDriver
            .drive(collectionView.rx.items) { cv, row, data in
                let cell = cv.dequeue(Reusable.genreInputCell, for: .init(row: row, section: 0))
                cell.bind(to: data)
                return cell
            }.disposed(by: disposeBag)
        
        viewModel.updateIndexSetDriver
            .drive(viewModel.selectedGenresRelay)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Initializer
    init(viewModel: GenreInputViewModel) {
        super.init(frame: .zero)
        setUI()
        bind(to: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    let titleLabel: UILabel = {
        $0.text = "장르 선택"
        $0.textColor = .init(hex: "#666666FF")
        $0.font = .appleSDGoithcFont(size: 16, style: .bold)
        return $0
    }(UILabel())
    let descriptionLabel: UILabel = {
        $0.text = "최대 3개까지 선택할 수 있습니다"
        $0.textColor = .init(hex: "#999999FF")
        $0.font = .appleSDGoithcFont(size: 12, style: .medium)
        return $0
    }(UILabel())
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cellSpacing: CGFloat = 12
        let sectionLeadingInset: CGFloat = 14
        let sectionTrailinginset: CGFloat = 14
        let cellWidth = (UIScreen.main.bounds.width - (cellSpacing * 4) - (sectionLeadingInset + sectionTrailinginset)) / 5
        layout.itemSize = .init(width: cellWidth, height: cellWidth)
        layout.minimumLineSpacing = cellSpacing
        layout.sectionInset = .init(top: 1, left: sectionLeadingInset, bottom: 1, right: sectionTrailinginset)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isScrollEnabled = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(Reusable.genreInputCell)
        cv.backgroundColor = .clear
        return cv
    }()
}

extension GenreInputView {
    func setUI() {
        [titleLabel, descriptionLabel, collectionView].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(((UIScreen.main.bounds.width - (12 * 4) - (14 + 14)) / 5) * 3 + 24)
            $0.bottom.equalToSuperview()
        }
    }
}
