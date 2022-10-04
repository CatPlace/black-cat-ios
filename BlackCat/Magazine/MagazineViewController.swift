//
//  MagazineViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/05.
//

import UIKit
import RxSwift
class MagazineViewController: UIViewController {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let viewModel = MagazineViewModel()
    
    // MARK: - Binding
    func bind() {
        
    }
    // function
    
    // MARK: - Initializing
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setUI()
    }
    
    // MARK: - UIComponents
    
}

extension MagazineViewController {
    func setUI() {
        
    }
}
