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
import SnapKit
import Nuke
struct MagazinePreviewCellViewModel {
    let fetchedMagazinePreviewDatas = PublishRelay<[PreviewMagazineData]>()
}

class MagazinePreviewCell: UITableViewCell {
    var disposeBag = DisposeBag()
    var viewModel = MagazinePreviewCellViewModel()
    
    func bind() {
        
    }
    
    let magazinePreviewCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: UIScreen.main.bounds.width / 2.0, height: UIScreen.main.bounds.width * (248 / 187.0))
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        let collectionView = DynamicHeightCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MagazineFamousItemCell.self, forCellWithReuseIdentifier: MagazineFamousItemCell.self.description())
        return collectionView
    }()
    
    
}

struct MagazinePreviewItemCellViewModel {
    let imageUrl: String
    let title: String
    let writer: String
    let date: String
}

class MagazinePreviewItemCell: UICollectionViewCell {
    
}


