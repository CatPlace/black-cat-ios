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
import Nuke

struct LastMagazineCellViewModel {
    let magazine: Magazine
    
    // MARK: - Output
    let imageUrlDriver: Driver<String>
    let titleDriver: Driver<String>
    let writerDriver: Driver<String>
    let dateDriver: Driver<String>
    
    init(magazine: Magazine) {
        self.magazine = magazine
        
        imageUrlDriver = Observable.just(magazine.imageUrl).asDriver(onErrorJustReturn: "")
        titleDriver = Observable.just(magazine.title).asDriver(onErrorJustReturn: "")
        writerDriver = Observable.just(magazine.writer).asDriver(onErrorJustReturn: "")
        dateDriver = Observable.just(magazine.date).asDriver(onErrorJustReturn: "")
    }
}

class LastMagazineCell: UICollectionViewCell {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: LastMagazineCellViewModel? {
        didSet {
            guard let viewModel else { return }
            bind(to: viewModel)
        }
    }
    
    // MARK: - Binding
    func bind(to viewModel: LastMagazineCellViewModel) {
        viewModel.imageUrlDriver
            .compactMap { URL(string: $0) }
            .drive {
                Nuke.loadImage(with: $0, into: self.lastMagazineImageView)
            }
            .disposed(by: disposeBag)
        
        viewModel.titleDriver
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.writerDriver
            .drive(writerLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.dateDriver
            .drive(dateLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    // MARK: - UIComponents
    let lastMagazineImageView = UIImageView()
    let titleLabel = UILabel()
    let writerLabel = UILabel()
    let dateLabel = UILabel()
}

extension LastMagazineCell {
    func setUI() {
        addSubview(lastMagazineImageView)
        
        [titleLabel, writerLabel, dateLabel].forEach {
            contentView.addSubview($0)
            $0.textColor = .white
        }
        contentView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        lastMagazineImageView.snp.makeConstraints {
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
