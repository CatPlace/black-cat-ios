//
//  MagazinePreviewCell.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/05.
//

import UIKit

import RxSwift
import RxCocoa
import RxRelay

struct MagazinePreviewCellViewModel {
    let fetchedMagazinePreviewDatas = PublishRelay<[PreviewMagazine]>()
}

class MagazinePreviewCell: UITableViewCell {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel = MagazinePreviewCellViewModel()
    
    // MARK: - Binding
    func bind() {
        viewModel.fetchedMagazinePreviewDatas
            .asDriver(onErrorJustReturn: [])
            .drive(magazinePreviewCollectionView.rx.items) { collectionView, row, data in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MagazinePreviewItemCell.self.description(), for: IndexPath(row: row, section: 0)) as? MagazinePreviewItemCell else { return UICollectionViewCell() }
                cell.viewModel = .init(
                    imageUrl: data.imageUrl,
                    title: data.title,
                    writer: data.writer,
                    date: data.date
                )
                
                return cell
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Life Cycle
    override func prepareForReuse() {
        disposeBag = DisposeBag()
        layoutIfNeeded()
    }
    
    // MARK: - UIComponents
    lazy var magazinePreviewCollectionView: DynamicHeightCollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width / 2.0 - 1
        
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.itemSize = .init(width: width, height: width * (243 / 187.0))
        let collectionView = DynamicHeightCollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.register(MagazinePreviewItemCell.self, forCellWithReuseIdentifier: MagazinePreviewItemCell.self.description())
        collectionView.isScrollEnabled = false
        return collectionView
    }()
}

extension MagazinePreviewCell {
    func setUI() {
        contentView.addSubview(magazinePreviewCollectionView)
        
        magazinePreviewCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}


