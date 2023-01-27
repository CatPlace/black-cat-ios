//
//  GenreInputCell.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/25.
//

import Foundation
import BlackCatSDK
class GenreInputCellViewModel: HomeGenreCellViewModel {
    var isSelected: Bool
    var genre: Model.Category
    
    init(genre: Model.Category, isSelected: Bool = false) {
        self.genre = genre
        self.isSelected = isSelected
        super.init(with: genre)
    }
}

class GenreInputCell: HomeGenreCell {
    func bind(to viewModel: GenreInputCellViewModel) {
        super.bind(to: .init(with: viewModel.genre))
        
        contentView.backgroundColor = viewModel.isSelected ? .init(hex: "#E4C6F2FF")?.withAlphaComponent(0.7) : .black.withAlphaComponent(0.7)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = .clear
    }
}
