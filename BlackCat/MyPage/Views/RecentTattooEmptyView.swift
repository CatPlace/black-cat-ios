//
//  RecentTattooEmptyView.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/03/06.
//

import UIKit
import RxCocoa
import RxSwift
class RecentTattooEmptyView: UICollectionReusableView {
    var disposeBag = DisposeBag()
    static let emptyLabelIsHidden = PublishRelay<Bool>()
    
    func bind() {
        RecentTattooEmptyView.emptyLabelIsHidden
            .bind(to: emptyLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        bind()
        backgroundColor = .clear
        setUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    let emptyLabel: UILabel = {
        $0.textColor = .init(hex: "#666666FF")
        
        let fullText = "최근본 타투가 없습니다."
        let attributeString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: "최근본 타투")
        attributeString.addAttributes([
            .font: UIFont.appleSDGoithcFont(size: 24, style: .bold)
        ], range: range)
        $0.attributedText = attributeString
        return $0
    }(UILabel())
}

extension RecentTattooEmptyView {
    func setUI() {
        addSubview(emptyLabel)
        
        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
