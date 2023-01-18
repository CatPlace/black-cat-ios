//
//  TattooInputView.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/18.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa
import BlackCatSDK

class TattooImageInputViewModel {
    // MARK: - Input
    let imageDataListRelay: BehaviorRelay<[Data?]>
    
    // MARK: - Output
    let cellViewModelsDrvier: Driver<[Data?]>
    let countLimitLabelTextDriver: Driver<String>
    
    init(imageDataList: [Data] = [Data(), Data()]) {
        var imageDataListInitialValue: Array<Data?> = .init(repeating: nil, count: 5)
        imageDataList.enumerated().forEach { index, data in
            imageDataListInitialValue[index] = data
        }
        
        imageDataListRelay = .init(value: imageDataListInitialValue)

        cellViewModelsDrvier = imageDataListRelay
            .asDriver(onErrorJustReturn: [])
        
        countLimitLabelTextDriver = imageDataListRelay
            .map { "(\($0.compactMap { $0 }.count)/\(5))" }
            .asDriver(onErrorJustReturn: "")
        
    }
}

class TattooImageInputView: UIView {
    
    enum Reusable {
        static let tattooImageInputCell = ReusableCell<TattooImageInputCell>()
    }
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: TattooImageInputViewModel
    let cellWidth: CGFloat = (UIScreen.main.bounds.width - 46) / 5
    
    // MARK: - Binding
    func bind(to viewModel: TattooImageInputViewModel) {
        viewModel.cellViewModelsDrvier
            .drive(collectionView.rx.items) { cv, row, viewModel in
                let cell = cv.dequeue(Reusable.tattooImageInputCell, for: IndexPath(row: row, section: 0))
                cell.configureCell(with: viewModel)
                return cell
            }.disposed(by: disposeBag)
        
        viewModel.countLimitLabelTextDriver
            .drive(limitLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Initializer
    init(viewModel: TattooImageInputViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        bind(to: viewModel)
        setUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    let titleLabel: UILabel = {
        $0.text = "사진"
        $0.textColor = .init(hex: "#666666FF")
        $0.font = .appleSDGoithcFont(size: 16, style: .bold)
        return $0
    }(UILabel())
    
    let limitLabel: UILabel = {
        let l = UILabel()
        $0.textColor = .init(hex: "#999999FF")
        $0.font = .appleSDGoithcFont(size: 12, style: .regular)
        return $0
    }(UILabel())
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = .init(width: cellWidth, height: cellWidth)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 1
        layout.sectionInset = .init(top: 1, left: 1, bottom: 1, right: 1)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.isScrollEnabled = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(Reusable.tattooImageInputCell)

        return cv
    }()
    
    func setUI() {
        [titleLabel, limitLabel, collectionView].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
        }
        
        limitLabel.snp.makeConstraints {
            $0.bottom.equalTo(titleLabel.snp.bottom).offset(6)
            $0.trailing.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(cellWidth + 2)
        }
    }
}

class TattooImageInputCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .white
        setUI()
    }
    
    func configureCell(with imageData: Data?) {
        controlImageView.image = UIImage(named: "addIcon")
        if let imageData {
            imageView.image = UIImage(data: imageData)
            contentView.backgroundColor = .black.withAlphaComponent(0.5)
            controlImageView.transform = controlImageView.transform.rotated(by: .pi/4)
        } else {
            imageView.backgroundColor = .init(hex: "#D9D9D9FF")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let imageView = UIImageView()
    let controlImageView = UIImageView()
    
    func setUI() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.addSubview(controlImageView)
        
        controlImageView.snp.makeConstraints {
            $0.width.height.equalTo(Constant.width * 22)
            $0.center.equalToSuperview()
        }
    }
}
