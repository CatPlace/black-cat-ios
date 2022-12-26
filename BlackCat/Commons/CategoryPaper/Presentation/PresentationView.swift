//
//  ListPresentationView.swift
//  BlackCat
//
//  Created by SeYeong on 2022/11/02.
//

import UIKit

final class PresentationView {
    let tableView: UITableView = {
        let tv = UITableView()
        tv.register(CategoryListTableViewCell.self,
                    forCellReuseIdentifier: CategoryListTableViewCell.identifier)
        tv.separatorStyle = .none
        tv.layer.cornerRadius = 30
        tv.isScrollEnabled = false
        return tv
    }()

    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    
    let menuWrapper = UIView()
}
