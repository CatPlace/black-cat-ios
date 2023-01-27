//
//  AreaInputView.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/12/28.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa
import BlackCatSDK

struct AreaCellModel {
    var name: String
    var isSelected: Bool
}

class AreaInputViewModel {
    let selectedAreaIndexRelay = PublishRelay<IndexPath>()
    let areaInputRelay: BehaviorRelay<Model.Area?>
    
    let updateAreaDriver: Driver<Model.Area?>
    let cellViewModelsDriver: Driver<[FilterCellViewModel]>

    init(area: Model.Area?) {
        areaInputRelay = .init(value: area)
        
        updateAreaDriver = selectedAreaIndexRelay
            .compactMap { Model.Area(rawValue: $0.row) }
            .withLatestFrom(areaInputRelay) { selectedArea, prevArea in
                selectedArea == prevArea ? nil : selectedArea
            }.asDriver(onErrorJustReturn: nil)
        
        cellViewModelsDriver = Observable.combineLatest(Observable.just(Model.Area.allCases),
                                                             areaInputRelay)
        .map { areas, selectedArea in
            areas.map { FilterCellViewModel(typeString: $0.asString(), isSubscribe: $0 == selectedArea) }
        }.asDriver(onErrorJustReturn: [])
    }
}

class AreaInputView: UIView {
    enum Reusable {
        static let areaCell = ReusableCell<FilterCell>()
    }
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Binding
    func bind(to viewModel: AreaInputViewModel) {
        disposeBag.insert {
            collectionView.rx.itemSelected
                .bind(to: viewModel.selectedAreaIndexRelay)
            
            viewModel.cellViewModelsDriver
                .drive(collectionView.rx.items) { cv, row, data in
                    let cell = cv.dequeue(Reusable.areaCell.self, for: IndexPath(row: row, section: 0))
                    
                    cell.viewModel = data
                    return cell
                }
            
            viewModel.updateAreaDriver
                .drive(viewModel.areaInputRelay)
        }
    }
    
    // MARK: - Initializer
    init(viewModel: AreaInputViewModel) {
        super.init(frame: .zero)
        setUI()
        bind(to: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    // MARK: - UIComponents
    let titleLabel: UILabel = {
        $0.text = "지역"
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
        $0.register(Reusable.areaCell.self)
        $0.isScrollEnabled = false
        $0.backgroundColor = .clear
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: layout))
    
    func setUI() {
        [titleLabel, collectionView].forEach { addSubview($0) }
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.height.equalTo(UIScreen.main.bounds.width * 100/375 * 0.4 * 3 + 10 * 2).priority(.high)
            $0.leading.trailing.bottom.equalToSuperview().inset(5)
        }
    }
}
