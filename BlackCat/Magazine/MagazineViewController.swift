//
//  MagazineViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/05.
//

import UIKit

import RxSwift
import SnapKit
import RxDataSources

struct FamousMagazineData {
    let imageUrl: String
}
struct PreviewMagazineData {
    let imageUrl: String
    let title: String
    let writer: String
    let date: String
}
struct MagazineSection {
    //    var header: String
    var items: [Item]
}
enum MagazineItem {
    case MagazineFamousCell([FamousMagazineData])
    case MagazinePreviewCell([PreviewMagazine])
}
//}
extension MagazineSection: SectionModelType {
    typealias Item = MagazineItem
    
    init(original: MagazineSection, items: [Item] = []) {
        self = original
        self.items = items
    }
}

class MagazineViewController: UIViewController {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let viewModel = MagazineViewModel()
    
    let dataSource = RxTableViewSectionedReloadDataSource<MagazineSection> { dataSource, tableView, indexPath, item in
        switch item {
            
        case .MagazineFamousCell(let datas):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MagazineFamousCell.self.description(), for: indexPath) as? MagazineFamousCell
            else { return UITableViewCell() }
            cell.bind()
            cell.setUI()
            cell.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * (500 / 375.0))
            cell.layoutIfNeeded()
            cell.viewModel.fetchedImageUrls.accept(datas.map { $0.imageUrl })
            
            return cell
            
        case .MagazinePreviewCell(let datas):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MagazinePreviewCell.self.description(), for: indexPath) as? MagazinePreviewCell else { return UITableViewCell() }
//            cell.bind()
            
            return cell
        }
        
    }
    
    // MARK: - Binding
    func bind() {
        viewModel.fetchedMagazineItems.bind(to: magazineTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    // function
    
    // MARK: - Initializing
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setUI()
        
        //test
        viewModel.magazineFamousCellItems.accept(FamousMagazine.dummy)
        viewModel.magazinePreviewCellItems.accept(PreviewMagazine.dummy)
        tempButton.rx.tap.bind { _ in
            self.viewModel.magazineFamousCellItems.accept(FamousMagazine.dummy2)
        }.disposed(by: disposeBag)
    }
    
    // MARK: - UIComponents
    let magazineTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MagazineFamousCell.self, forCellReuseIdentifier: MagazineFamousCell.self.description())
        tableView.register(MagazinePreviewCell.self, forCellReuseIdentifier: MagazinePreviewCell.self.description())
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500
        return tableView
    }()
    
    let tempButton = UIButton()
}


extension MagazineViewController {
    func setUI() {
        view.addSubview(magazineTableView)
        
        magazineTableView.contentInsetAdjustmentBehavior = .never
        
        magazineTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(tempButton)
        tempButton.setTitle("asdasdasd", for: .normal)
        tempButton.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

    }
}
