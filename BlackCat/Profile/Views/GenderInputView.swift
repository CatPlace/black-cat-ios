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
    let genders: [Model.Gender]
    
    // MARK: Input
    let genderCellInfosRelay = BehaviorRelay<[GenderCellModel]>(
        value: Model.Gender.allCases
            .map {.init(
                name: $0.asString(),
                isSelected: $0 == CatSDKUser.userCache().gender )
            }
    )
    let selectedGenderIndexRelay = PublishRelay<IndexPath>()
    
    // MARK: Output
    let cellViewModelsDriver: Driver<[FilterCellViewModel]>
    let shouldUpdateGenderCells: Driver<Model.Gender>
    
    
    init(genders: [Model.Gender] = Model.Gender.allCases) {
        print(CatSDKUser.user())
        self.genders = genders
        
        CatSDKUser.initUserCache()
        
        self.cellViewModelsDriver = genderCellInfosRelay.map {
            $0.map { .init(typeString: $0.name, isSubscribe: $0.isSelected)}
        }.asDriver(onErrorJustReturn: [])
        
        shouldUpdateGenderCells = selectedGenderIndexRelay
            .map { $0.row }
            .withLatestFrom(genderCellInfosRelay) { ($0, $1) }
            .map { selectedRow, genderCellInfos in
                return updateGender(with: selectedRow)
            }.asDriver(onErrorJustReturn: .남자)
        
        
        func updateGender(with row: Int? = nil) -> Model.Gender {
            var user = CatSDKUser.userCache()
            if let row {
                user.gender = Model.Gender(rawValue: row)
                CatSDKUser.updateUserCache(user: user)
            }
            return user.gender ?? .남자
        }
    }
    
    func updateCelles(selectedGender: Model.Gender) {
        genderCellInfosRelay.accept(genders.map { .init(name: $0.asString(), isSelected: $0 == selectedGender)})
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
            viewModel.cellViewModelsDriver
                .drive(collectionView.rx.items) { cv, row, data in
                    let cell = cv.dequeue(Reusable.genderCell.self, for: IndexPath(row: row, section: 0))
                    
                    cell.viewModel = data
                    return cell
                }
            //TODO: - itemSelected
            collectionView.rx.itemSelected
                .debug("아이템 선택")
                .bind(to: viewModel.selectedGenderIndexRelay)
            
            viewModel.shouldUpdateGenderCells
                .drive { viewModel.updateCelles(selectedGender: $0) }
            
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
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: layout))
    
    func setUI() {
        [titleLabel, collectionView].forEach { addSubview($0) }
        titleLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }
        collectionView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing)
            $0.height.equalTo(UIScreen.main.bounds.width * 100/375 * 0.4).priority(.high)
            $0.trailing.top.bottom.equalToSuperview()
        }
    }
}

extension GenderInputView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
}
