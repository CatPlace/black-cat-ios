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
import SnapKit
import Nuke
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
//                cell.layoutIfNeeded()
                return cell
            }.disposed(by: disposeBag)
    }
    // function

    // MARK: - Initializing
    
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
        collectionView.register(MagazineFamousItemCell.self, forCellWithReuseIdentifier: MagazineFamousItemCell.self.description())
        return collectionView
    }()
    let magazineFamouspageControl = UIPageControl()
}

extension MagazineFamousCell {
    func setUI() {
        contentView.addSubview(magazineFamousCollectionView)

        magazineFamousCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}


struct MagazineFamousItemCellViewModel {
    let imageUrl: String
}

class MagazineFamousItemCell: UICollectionViewCell {
    // MARK: - Properties
    private var disposeBag = DisposeBag()
    var viewModel: MagazineFamousItemCellViewModel? {
        didSet {
            setImage()
            setUI()
        }
    }

    // MARK: - UIComponents
    let famouseMagazineImageView = UIImageView()
}

extension MagazineFamousItemCell {
    
    func setImage() {
        guard let viewModel, let url = URL(string: viewModel.imageUrl) else { return }
        let request = ImageRequest(url: url,priority: .high)
        Nuke.loadImage(with: request, into: famouseMagazineImageView)
    }
    
    func setUI() {
        contentView.addSubview(famouseMagazineImageView)
        
        famouseMagazineImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}

class DynamicHeightCollectionView: UICollectionView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return collectionViewLayout.collectionViewContentSize
    }
    
}
