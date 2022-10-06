//
//  MagazineFamouseCell.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/05.
//

import UIKit

import RxSwift
import RxCocoa
import RxRelay

struct MagazineFamousCellViewModel {
    let fetchedImageUrls = PublishRelay<[String]>()
}

class MagazineFamousCell: UITableViewCell {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel = MagazineFamousCellViewModel()
    
    
    // MARK: - Binding
    func bind() {
        
        viewModel.fetchedImageUrls
            .asDriver(onErrorJustReturn: [])
            .drive(magazineFamousCollectionView.rx.items) { collectionView, row, data in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MagazineFamousItemCell.self.description(), for: IndexPath(row: row, section: 0)) as? MagazineFamousItemCell else { return UICollectionViewCell() }
                
                cell.viewModel = .init(imageUrl: data)
                cell.layoutIfNeeded()
                return cell
            }.disposed(by: disposeBag)
        
        magazineFamousCollectionView.rx.willEndDragging
            .bind { velocity, targetOffset in
                let page = Int(targetOffset.pointee.x / UIScreen.main.bounds.width)
                self.magazineFamouspageControl.set(progress: page, animated: true)
            }.disposed(by: disposeBag)
        
        viewModel.fetchedImageUrls
            .map { $0.count }
            .bind(to: magazineFamouspageControl.rx.numberOfPages)
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Life Cycle
    override func prepareForReuse() {
        disposeBag = DisposeBag()
        layoutIfNeeded()
    }
    
    // MARK: - UIComponents
    let magazineFamousCollectionView: DynamicHeightCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * (500 / 375.0))
        layout.minimumLineSpacing = 1
        layout.scrollDirection = .horizontal
        let collectionView = DynamicHeightCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(MagazineFamousItemCell.self, forCellWithReuseIdentifier: MagazineFamousItemCell.self.description())
        return collectionView
    }()
    let magazineFamouspageControl = JHPageControl()
}

extension MagazineFamousCell {
    func setUI() {
        [magazineFamousCollectionView, magazineFamouspageControl].forEach {
            contentView.addSubview($0)
        }
        magazineFamouspageControl.tintColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1)
        magazineFamouspageControl.currentPageTintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        magazineFamouspageControl.progress = 0.5
        magazineFamouspageControl.set(progress: 0, animated: false)
        magazineFamouspageControl.radius = 3
        magazineFamouspageControl.elementWidth = 30
        magazineFamouspageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(UIScreen.main.bounds.width * (500 / 375.0) * 0.05)
        }
        
        magazineFamousCollectionView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(magazineFamouspageControl.snp.top)
        }
        
    }
}
