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
        case .imageCell(let reactor):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MagazineDetailImageCell.identifier,
                for: indexPath
            ) as? MagazineDetailImageCell else { return UITableViewCell() }
            
            cell.reactor = reactor
            return cell
        }
    }
    
    // MARK: - Binding
    func bind(reactor: Reactor) {
        dispatch(reactor: reactor)
        render(reactor: reactor)
    }
    
    private func dispatch(reactor: Reactor) {
        
    }
    
    private func render(reactor: Reactor) {
        reactor.state.map { $0.sections }
            .asObservable()
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    // MARK: - Initialize
    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIComponents
    lazy var tableView: UITableView = {
        var tv = UITableView(frame: .zero, style: .plain)
        tv.register(MagazineDetailTextCell.self, forCellReuseIdentifier: MagazineDetailTextCell.identifier)
        tv.register(MagazineDetailImageCell.self, forCellReuseIdentifier: MagazineDetailImageCell.identifier)
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 70
        return tv
    }()
}

extension MagazineDetailViewController {
    func setUI() {
        [tableView].forEach { view.addSubview($0) }
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
}
