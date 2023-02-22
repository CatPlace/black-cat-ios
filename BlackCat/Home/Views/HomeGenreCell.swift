//
//  HomeCategoryCell.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/05.
//

import UIKit

import BlackCatSDK
import RxCocoa
import RxSwift
import SnapKit

class HomeGenreCell: UICollectionViewCell {

    // MARK: - Properties
    
    let disposeBag = DisposeBag()

    // MARK: - Binding

    func bind(to viewModel: HomeGenreCellViewModel) {
        categoryTitleLabel.text = viewModel.category.title
        categoryImageView.image = .init(named: viewModel.category.imageName)
    }

    // MARK: - Initializing

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUI()
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func prepareForReuse() {
        categoryImageView.image = nil
    }
    
    // MARK: - UIComponents
    let categoryTitleLabel = UILabel()
    let categoryImageView = UIImageView()
}

extension HomeGenreCell {
    private func configure() {
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        contentView.backgroundColor = .black.withAlphaComponent(0.7)
        
        categoryTitleLabel.textAlignment = .center
        categoryTitleLabel.numberOfLines = 0
        categoryTitleLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
        categoryTitleLabel.textColor = .white
    }
    
    private func setUI() {

        addSubview(categoryImageView)
        
        categoryImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.addSubview(categoryTitleLabel)

        categoryTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(9)
            $0.trailing.equalToSuperview().inset(9)
            $0.centerX.centerY.equalToSuperview()
        }
    }
}
