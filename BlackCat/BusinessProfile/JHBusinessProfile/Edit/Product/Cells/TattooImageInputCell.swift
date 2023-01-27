//
//  TattooImageInputCell.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/21.
//

import UIKit
import RxSwift
import RxCocoa
class TattooImageInputCell: UICollectionViewCell {
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .white
        setUI()
    }
    
    func configureCell(with sender: Any?) {
        print(sender)
        convertToUIImage(sender)
            .asDriver(onErrorJustReturn: nil)
            .drive(imageView.rx.image)
            .disposed(by: disposeBag)
        
        controlImageView.image = UIImage(named: "addIcon")
        if sender != nil {
            contentView.backgroundColor = .black.withAlphaComponent(0.5)
            controlImageView.transform = controlImageView.transform.rotated(by: .pi/4)
        } else {
            imageView.backgroundColor = .init(hex: "#D9D9D9FF")
        }
    }
    
    func convertToUIImage(_ sender: Any?) -> Observable<UIImage?> {
        if let data = sender as? Data {
            return .just(UIImage(data: data))
        } else if let string = sender as? String, let url = URL(string: string) {
            return URLSession.shared.rx.response(request: URLRequest(url: url)).map { UIImage(data: $1) }
        } else if let image = sender as? UIImage {
            return .just(image)
        }
        else {
            return .just(nil)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func prepareForReuse() {
        imageView.image = nil
        contentView.backgroundColor = .clear
        controlImageView.transform = CGAffineTransformIdentity
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
