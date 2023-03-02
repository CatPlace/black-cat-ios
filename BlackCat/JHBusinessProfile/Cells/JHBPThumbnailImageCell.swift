//
//  JHBPThumbnailImageCell.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/12/29.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import Nuke

final class JHBPThumbnailImageCellViewModel {
    let imageUrlStringDriver: Driver<String>
    let isEmptyCoverImageDriver: Driver<Bool>
    init(imageUrlString: String?) {
        let imageUrlString = Observable.just(imageUrlString)
        self.imageUrlStringDriver = imageUrlString
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "")
        
        self.isEmptyCoverImageDriver = imageUrlString
            .debug("💡")
            .map { $0 == nil }
            .filter { $0 }
            .asDriver(onErrorJustReturn: false)
    }
    
}
final class JHBPThumbnailImageCell: BPBaseCollectionViewCell {
    func bind(viewModel: JHBPThumbnailImageCellViewModel) {
        viewModel.imageUrlStringDriver
            .compactMap { URL(string: $0) }
            .drive(with: self) { owner, url in
                Nuke.loadImage(with: url, into: owner.thumnailImageView)
            }.disposed(by: disposeBag)
        
        viewModel.isEmptyCoverImageDriver
            .drive(with: self) { owner, _ in
                owner.thumnailImageView.image = .init(named: "defaultCover")
            }.disposed(by: disposeBag)
    }
    
    // MARK: - initialize
    override func initialize() {
        self.setUI()
    }
    
    private func setUI() {
        contentView.addSubview(thumnailImageView)
        // 🐻‍❄️ NOTE: - Pin + Flex 조합으로 변경 가능하면 바꾸기
        thumnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func prepareForReuse() {
        thumnailImageView.image = .init(named: "defaultCover")
    }
    
    let thumnailImageView: UIImageView = {
        $0.image = .init(named: "defaultCover")
        return $0
    }(UIImageView())
}

