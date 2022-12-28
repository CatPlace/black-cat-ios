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
    let areas: [Model.Area]
    let areaCellInfosRelay = BehaviorRelay<[AreaCellModel]>(
        value: Model.Area.allCases
            .map {.init(
                name: $0.asString(),
                isSelected: CatSDKUser.userCache().areas.contains($0) )
            }
    )
    let selectedAreaIndexRelay = PublishRelay<IndexPath>()
    let updateAreaCellsDriver: Driver<Set<Model.Area>>
    let cellViewModelsDriver: Driver<[FilterCellViewModel]>
    //    let shouldUpdateAreaCells: Driver<Model.Area>
    init() {
        areas = Model.Area.allCases
    
        self.cellViewModelsDriver = areaCellInfosRelay.map {
            $0.map { .init(typeString: $0.name, isSubscribe: $0.isSelected)}
        }.asDriver(onErrorJustReturn: [])
        
        updateAreaCellsDriver = selectedAreaIndexRelay
            .map { $0.row }
            .withLatestFrom(areaCellInfosRelay) { ($0, $1) }
            .map { selectedRow, areaCellInfos in
                return updateArea(with: selectedRow)
            }.asDriver(onErrorJustReturn: Set())
        
        func updateArea(with row: Int? = nil) -> Set<Model.Area> {
            var user = CatSDKUser.userCache()
            if let row {
                var newAreas = user.areas
                if let selectedArea = Model.Area(rawValue: row) {
                    if newAreas.contains(selectedArea) {
                        newAreas.remove(selectedArea)
                    } else {
                        newAreas.insert(selectedArea)
                    }
                }
                user.areas = newAreas
                CatSDKUser.updateUserCache(user: user)
            }
            return user.areas
        }
    }
    
    func updateCells(selectedAreas: Set<Model.Area>) {
        areaCellInfosRelay.accept(
            areas.map { .init(name: $0.asString(), isSelected: selectedAreas.contains($0)) }
        )
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
            viewModel.cellViewModelsDriver
                .drive(collectionView.rx.items) { cv, row, data in
                    let cell = cv.dequeue(Reusable.areaCell.self, for: IndexPath(row: row, section: 0))
                    
                    cell.viewModel = data
                    return cell
                }
            
            viewModel.updateAreaCellsDriver
                .drive { viewModel.updateCells(selectedAreas: $0) }
            
            collectionView.rx.itemSelected
                .bind(to: viewModel.selectedAreaIndexRelay)
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
