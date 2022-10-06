//
//  MagazineDetailViewController.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/06.
//

import UIKit
import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift

final class MagazineDetailViewController: UIViewController, View {
    typealias Reactor = MagazineDetailViewReactor
    typealias ManageMentDataSource = RxTableViewSectionedAnimatedDataSource<MagazineDetailCellSection>

    // MARK: - Properties
    var disposeBag: DisposeBag = DisposeBag()
    let dataSource: ManageMentDataSource = ManageMentDataSource { _, tableView, indexPath, items in
        switch items {
        case .textCell(let reactor):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MagazineDetailTextCell.identifier,
                for: indexPath
            ) as? MagazineDetailTextCell else { return UITableViewCell() }
            
            cell.reactor = reactor
            return cell
        }
    }
    
    // MARK: - Binding
    func bind(reactor: Reactor) {
        //
    }
    
    // MARK: UIComponents
    lazy var tableView: UITableView = {
        var tv = UITableView(frame: .zero, style: .plain)
        tv.register(MagazineDetailTextCell.self, forCellReuseIdentifier: MagazineDetailTextCell.identifier)
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 70
        return tv
    }()
}

extension MagazineDetailViewController {
    func setUI() { }
    
}
