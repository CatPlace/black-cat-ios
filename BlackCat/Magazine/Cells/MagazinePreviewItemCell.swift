//
//  MagazinePreviewItemCell.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/07.
//

import UIKit

import SnapKit
import Nuke

struct MagazinePreviewItemCellViewModel {
    let imageUrl: String
    let title: String
    let writer: String
    let date: String
}

class MagazinePreviewItemCell: UICollectionViewCell {
    // MARK: - Properties
    var viewModel: MagazinePreviewItemCellViewModel? {
        didSet {
            setImage()
            titleLabel.text = viewModel?.title
            writerLabel.text = viewModel?.writer
            dateLabel.text = viewModel?.date
            setUI()
        }
    }
    
    // MARK: - UIComponents
    let previewMagazineImageView = UIImageView()
    let titleLabel = UILabel()
    let writerLabel = UILabel()
    let dateLabel = UILabel()
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
