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
    var tempView = UIView()
    func bind() {
        viewModel.fetchedMagazinePreviewDatas
            .asDriver(onErrorJustReturn: [])
            .drive(magazinePreviewCollectionView.rx.items) { collectionView, row, data in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MagazinePreviewItemCell.self.description(), for: IndexPath(row: row, section: 0)) as? MagazinePreviewItemCell else { return UICollectionViewCell() }
                print(data)
                if cell.viewModel == nil {
                    cell.viewModel = .init(
                        imageUrl: data.imageUrl,
                        title: data.title,
                        writer: data.writer,
                        date: data.date
                    )
                }
//                print("\n")
//                print(data)
//                print("cellFrame: ",cell.frame)
////                 cell.frame.maxX < 300 ?
//                print(self.magazinePreviewCollectionView.contentSize,"asd")
//                print("\n")
                return cell
            }.disposed(by: disposeBag)
    }
    
    lazy var magazinePreviewCollectionView: DynamicHeightCollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width / 2.0 - 1
        
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.itemSize = .init(width: width, height: width * (243 / 187.0))
        let collectionView = DynamicHeightCollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.register(MagazinePreviewItemCell.self, forCellWithReuseIdentifier: MagazinePreviewItemCell.self.description())
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .red
        return collectionView
    }()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
}

extension MagazinePreviewCell {
    func setUI() {
        contentView.addSubview(magazinePreviewCollectionView)
        
        magazinePreviewCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

struct MagazinePreviewItemCellViewModel {
    let imageUrl: String
    let title: String
    let writer: String
    let date: String
}

class MagazinePreviewItemCell: UICollectionViewCell {
    let previewMagazineImageView = UIImageView()
    let titleLabel = UILabel()
    let writerLabel = UILabel()
    let dateLabel = UILabel()
    var viewModel: MagazinePreviewItemCellViewModel? {
        didSet {
            setImage()
            titleLabel.text = viewModel?.title
            writerLabel.text = viewModel?.writer
            dateLabel.text = viewModel?.date
            setUI()
        }
    }
    
    func setImage() {
        guard let viewModel, let url = URL(string: viewModel.imageUrl) else { return }
        let request = ImageRequest(url: url,priority: .high)
        Nuke.loadImage(with: request, into: previewMagazineImageView)
    }
    
    func setUI() {
        addSubview(previewMagazineImageView)
        
        [titleLabel, writerLabel, dateLabel].forEach {
            contentView.addSubview($0)
            $0.textColor = .white
        }
        contentView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        previewMagazineImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dateLabel.font = .systemFont(ofSize: 14)
        
        dateLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(21)
        }
        
        writerLabel.font = .systemFont(ofSize: 14)
        
        writerLabel.snp.makeConstraints {
            $0.bottom.equalTo(dateLabel.snp.top)
            $0.leading.equalTo(dateLabel)
        }
        
        titleLabel.font = .boldSystemFont(ofSize: 18)
        
        titleLabel.snp.makeConstraints {
            $0.bottom.equalTo(writerLabel.snp.top).offset(-5)
            $0.leading.equalTo(dateLabel)
        }
    }

}


