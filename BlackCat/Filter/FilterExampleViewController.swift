//
//  FilterExampleViewController.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/15.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class FilterExampleViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(button)
        button.setTitle("도라에몽 주머니", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        button.rx.tap
            .debug("didTapTouched")
            .bind { [weak self] _ in
                let vc = SparseContentSheetViewController()
                vc.preferredSheetSizing = .medium
                self?.present(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    let button = UIButton()
    let disposeBag = DisposeBag()
}


final class SparseContentSheetViewController: BottomSheetController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setUI()
    }
    
    private lazy var titleLabel: UILabel = {
        $0.text = "필터 검색"
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 28, weight: .semibold)
        return $0
    }(UILabel())
    
}

extension SparseContentSheetViewController {
    func setUI() {
        [titleLabel].forEach { view.addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide)
        }
        titleLabel.backgroundColor = .red
        view.backgroundColor = .orange

    }
}

class FilterTitleCell: FilterBaseCell {
    
}
