//
//  GenreInputView.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/19.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

enum GenreInput: Int, CaseIterable {
    case lettering
    case mini
    case 감성
    case 이레즈미
    case blackAndGray
    case lineWork
    case 헤나
    case coverUp
    case newSchool
    case oldSchool
    case inkSplash
    case chicano
    case color
    case character
    
    func asTitle() -> String {
        switch self {
        case .lettering: return "레터링"
        case .mini: return "미니 타투"
        case .감성: return "감성 타투"
        case .이레즈미: return "이레즈미"
        case .blackAndGray: return "블랙&\n그레이"
        case .lineWork: return "라인워크"
        case .헤나: return "혜나"
        case .coverUp: return "커버업"
        case .newSchool: return "뉴스쿨"
        case .oldSchool: return "올드스쿨"
        case .inkSplash: return "잉크\n스플래쉬"
        case .chicano: return "치카노"
        case .color: return "컬러"
        case .character: return "캐릭터"
        }
    }
}
class GenreInputCell {
    
}
class GenreInputViewModel {
    
}

class GenreInputView: UIView {
//    enum Reusable {
//        static let genreInputCell = ReusableCell<TattooImageInputCell>()
//    }
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Binding
    func bind(to viewModel: GenreInputViewModel) {
        
    }
    
    // MARK: - Initializer
    init(viewModel: GenreInputViewModel) {
        super.init(frame: .zero)
        setUI()
        bind(to: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    let titleLabel: UILabel = {
        $0.text = "장르 선택"
        $0.textColor = .init(hex: "#666666FF")
        $0.font = .appleSDGoithcFont(size: 16, style: .bold)
        return $0
    }(UILabel())
    let descriptionLabel: UILabel = {
        $0.text = "최대 3개까지 선택할 수 있습니다"
        $0.textColor = .init(hex: "#999999FF")
        $0.font = .appleSDGoithcFont(size: 12, style: .medium)
        return $0
    }(UILabel())
//    lazy var collectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        
//        layout.itemSize = .init(width: cellWidth, height: cellWidth)
//        layout.scrollDirection = .horizontal
//        layout.minimumLineSpacing = 1
//        layout.sectionInset = .init(top: 1, left: 1, bottom: 1, right: 1)
//        
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.backgroundColor = .white
//        cv.isScrollEnabled = false
//        cv.showsHorizontalScrollIndicator = false
//        cv.register(Reusable.tattooImageInputCell)
//
//        return cv
//    }()
}

extension GenreInputView {
    func setUI() {
        [titleLabel, descriptionLabel].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
