//
//  GenderInputView.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/12/28.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa
import BlackCatSDK

struct GenderCellModel {
    var name: String
    var isSelected: Bool
}

class GenderInputViewModel {
    // MARK: Input
    let selectedGenderIndexRelay = PublishRelay<IndexPath>()
    let genderInputRelay: BehaviorRelay<Model.Gender?>
    
    // MARK: Output
    let cellViewModelsDriver: Driver<[FilterCellViewModel]>
    let updateGenderDriver: Driver<Model.Gender?>
    
    init(gender: Model.Gender? = nil) {
        genderInputRelay = .init(value: gender)
        
        updateGenderDriver = selectedGenderIndexRelay
            .compactMap { Model.Gender(rawValue: $0.row) }
            .withLatestFrom(genderInputRelay) { selectedGender, prevGender in
                selectedGender == prevGender ? nil : selectedGender
            }.asDriver(onErrorJustReturn: nil)
        
        cellViewModelsDriver = Observable.combineLatest(Observable.just(Model.Gender.allCases),
                                                             genderInputRelay)
        .map { genders, selectedGender in
            genders.map { FilterCellViewModel(typeString: $0.asString(), isSubscribe: $0 == selectedGender) }
        }.asDriver(onErrorJustReturn: [])
    }
}

class GenderInputView: UIView {
    enum Reusable {
        static let genderCell = ReusableCell<FilterCell>()
    }
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: GenderInputViewModel
    
    // MARK: - Binding
    func bind(to viewModel: GenderInputViewModel) {
        disposeBag.insert {
            collectionView.rx.itemSelected
                .bind(to: viewModel.selectedGenderIndexRelay)
            
            viewModel.cellViewModelsDriver
                .drive(collectionView.rx.items) { cv, row, data in
                    let cell = cv.dequeue(Reusable.genderCell.self, for: IndexPath(row: row, section: 0))
                    
                    cell.viewModel = data
                    return cell
                }
            
            viewModel.updateGenderDriver
                .drive(viewModel.genderInputRelay)
        }
    }
    
    // MARK: - Initializer
    init(viewModel: GenderInputViewModel) {
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
        $0.text = "성별"
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
        $0.register(Reusable.genderCell.self)
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
