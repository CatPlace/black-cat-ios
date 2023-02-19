//
//  VerticalScrollableViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/18.
//

import UIKit

class VerticalScrollableViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let scrollView = UIScrollView()
    let contentView = UIView()

    override func viewDidLoad() {
        setupLayout()
    }
    
    func setupLayout() {
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
    }
}
