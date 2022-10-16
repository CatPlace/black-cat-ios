//
//  FilterViewController.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/15.
//

import UIKit
import RxSwift
import SnapKit
import RxCocoa
import BlackCatSDK

final class FilterViewController: BottomSheetController {
    typealias ViewModel = FilterViewModel
    
    enum Reuable {
        static let filterCell = ReusableCell<FilterCell>()
    }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let viewModel = ViewModel()
    
    // MARK: - Binding
    private func bind(_ viewModel: ViewModel) {
        dispatch(viewModel)
        render(viewModel)
    }
    
    private func dispatch(_ viewModel: ViewModel) { }
    
    private func render(_ viewModel: ViewModel) {
        viewModel.taskDriver
            .drive(taskCollectionView.rx.items(Reuable.filterCell)) { row, item, cell in
                cell.viewModel = .init(item: item)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        setUI()
        bind(viewModel)
    }
    
    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        $0.text = "필터 검색"
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 28, weight: .semibold)
        return $0
    }(UILabel())
    
    // NOTE: - 구분선: 0과 1
    private lazy var dividerView01: UIView = {
        viewModel.divierViewModifier($0)
        return $0
    }(UIView())
    
    // NOTE: - 작업 종류 선택
    private lazy var taskSectionTitleLabel: UILabel = {
        viewModel.sectionTitleModifier($0)
        $0.text = "작업 종류를 선택해주세요."
        return $0
    }(UILabel())
    
    private lazy var taskCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.delegate = self

        cv.register(Reuable.filterCell)
        return cv
    }()
    
    // NOTE: - 구분선: 1과 2
    private lazy var dividerView12 = UIView()
    
    // NOTE: - 지역 선택
//    private lazy var loactionSectionTitleLabel = UILabel()
//    private lazy var loactionCollectionView = UICollectionView()
    
    // NOTE: - 완료 버튼
    private lazy var applyButton = UIButton()
}

extension FilterViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // NOTE: - TaskCollectionView
        if collectionView == taskCollectionView {
            
            print("😇맞")
        } else {
            print("아닌")
        }
        
        return CGSize(width: 100, height: 50)
    }
}

extension FilterViewController {
    func setUI() {
        view.backgroundColor = .white
        // NOTE: - UI에 그려지는 상태대로 정렬
        [titleLabel,
         dividerView01,
         taskSectionTitleLabel, taskCollectionView,
//         dividerView12,
//         loactionSectionTitleLabel, loactionCollectionView,
         applyButton].forEach { view.addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(28)
        }
        
        dividerView01.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        taskSectionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(dividerView01.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(28)
        }
        
        taskCollectionView.snp.makeConstraints {
            $0.top.equalTo(taskSectionTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(26)
            $0.bottom.equalToSuperview()
        }
//
//        dividerLineView12.snp.makeConstraints {
//            $0.height.equalTo(1)
//            $0.top.equalTo(taskCollectionView.snp.bottom).offset(20)
//            $0.leading.trailing.equalToSuperview().inset(20)
//        }
        
        applyButton.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
    }
}
