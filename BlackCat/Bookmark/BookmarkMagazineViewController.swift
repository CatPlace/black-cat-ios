//
//  BookmarkMagazineViewController.swift
//  BlackCat
//
//  Created by SeYeong on 2022/11/10.
//

import UIKit

import SnapKit

class BookmarkMagazineViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private let label: UILabel = {
        $0.text = "BookmarkMagazine"
        return $0
    }(UILabel())
}
