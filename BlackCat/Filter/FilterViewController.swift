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
    let viewModel: ViewModel
    
    // MARK: - Binding
    private func bind(_ viewModel: ViewModel) {
        dispatch(viewModel)
        render(viewModel)
    }
    
    private func dispatch(_ viewModel: ViewModel) { }
    
    private func render(_ viewModel: ViewModel) {
        viewModel.taskDriver
            .asObservable()
            .bind(to: taskCollectionView.rx.items(Reuable.filterCell)) { row, item, cell in
                
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Initialize
    init(viewModel: ViewModel = ViewModel()) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
        setUI()
        bind(viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - function
    // 구분선 Modifier
    fileprivate func divierViewModifier(_ sender: UIView) {
        sender.backgroundColor = .darkGray
    }
    
    // 섹션 타이틀 Modifier
    fileprivate func sectionTitleModifier(_ sender: UILabel) {
        sender.textAlignment = .center
        sender.textColor = .gray
        sender.font = .systemFont(ofSize: 14, weight: .medium)
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
        divierViewModifier($0)
        return $0
    }(UIView())
    
    // NOTE: - 작업 종류 선택
    private lazy var taskSectionTitleLabel: UILabel = {
        sectionTitleModifier($0)
        return $0
    }(UILabel())
    
    private lazy var taskCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
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

extension FilterViewController {
    func setUI() {
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
            $0.top.equalToSuperview().inset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(28)
        }
        
        taskCollectionView.snp.makeConstraints {
            $0.top.equalTo(taskSectionTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(26)
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
