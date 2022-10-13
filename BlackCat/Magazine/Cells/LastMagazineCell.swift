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
    // MARK: - Output
    let imageUrlStringDriver: Driver<String>
    let titleDriver: Driver<String>
    let writerDriver: Driver<String>
    let dateStringDriver: Driver<String>
    
    init(magazine: Magazine) {
        imageUrlStringDriver = Observable.just(magazine.imageUrlString).asDriver(onErrorJustReturn: "")
        titleDriver = Observable.just(magazine.title).asDriver(onErrorJustReturn: "")
        writerDriver = Observable.just(magazine.writer).asDriver(onErrorJustReturn: "")
        dateStringDriver = Observable.just(magazine.dateString).asDriver(onErrorJustReturn: "")
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
        viewModel.imageUrlStringDriver
            .compactMap { URL(string: $0) }
            .drive { [weak self] in
                guard let self else { return }
                Nuke.loadImage(with: $0, into: self.lastMagazineImageView)
            }.disposed(by: disposeBag)
        
        viewModel.titleDriver
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.writerDriver
            .drive(writerLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.dateStringDriver
            .drive(dateLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        contentView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    // MARK: - UIComponents
    let lastMagazineImageView = UIImageView()
    let titleLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .boldSystemFont(ofSize: 18)
        return l
    }()
    let writerLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 14)
        return l
    }()
    let dateLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 14)
        return l
    }()
}

extension LastMagazineCell {
    func setUI() {
        addSubview(lastMagazineImageView)
        
        lastMagazineImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        [titleLabel, writerLabel, dateLabel].forEach { contentView.addSubview($0) }
        
        dateLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(21)
        }
        
        writerLabel.snp.makeConstraints {
            $0.bottom.equalTo(dateLabel.snp.top)
            $0.leading.equalTo(dateLabel)
        }
        
        titleLabel.snp.makeConstraints {
            $0.bottom.equalTo(writerLabel.snp.top).offset(-5)
            $0.leading.equalTo(dateLabel)
        }
    }
}
