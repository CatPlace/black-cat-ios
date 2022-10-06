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
    var magazineTableViewTopInset = PublishSubject<CGFloat>()
    
    // 섹션마다 다른셀을 주기 위해 rxDataSource사용
    lazy var dataSource = RxTableViewSectionedReloadDataSource<MagazineSection> { dataSource, tableView, indexPath, item in
        
        switch item {
            
        case .MagazineFamousCellItem(let datas):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MagazineFamousCell.self.description(), for: indexPath) as? MagazineFamousCell
            else { return UITableViewCell() }
            cell.bind()
            cell.viewModel.fetchedImageUrls.accept(datas.map { $0.imageUrl })
            cell.setUI()
            cell.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * (500 / 375.0) * 1.05)
            cell.layoutIfNeeded()
            return cell
            
        case .MagazinePreviewCellItem(let datas):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MagazinePreviewCell.self.description(), for: indexPath) as? MagazinePreviewCell else { return UITableViewCell() }
            cell.bind()
            cell.setUI()
            cell.viewModel.fetchedMagazinePreviewDatas.accept(datas)
            cell.layoutIfNeeded()
            return cell
            
        }
    }
    
    // MARK: - Binding
    func bind() {
        
        viewModel.fetchedMagazineItems
            .bind(to: magazineTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        magazineTableViewTopInset.distinctUntilChanged()
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe { owner, inset in
                owner.magazineTableView.contentInset = .init(top: inset, left: 0, bottom: 0, right: 0)
            }.disposed(by: disposeBag)
        
        magazineTableView.rx.contentOffset
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] point in
                guard let self else { return }
                
                // 기본 tableView section header로 스크롤시 header 고정은 시켰지만 좀더 아래에 고정시키고 싶어서 사용
                if point.y > 200 {
                    self.magazineTableViewTopInset.onNext(26)
                } else {
                    self.magazineTableViewTopInset.onNext(0)
                }
                
                // 페이지 네이션
                if point.y > self.magazineTableView.contentSize.height - self.view.frame.height - 200 {
                    self.viewModel.updateTrigger.accept(1)
                }
                
            }.disposed(by: disposeBag)
        
        
        magazineTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        bind()
        magazineTableView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - UIComponents
    let magazineTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MagazineFamousCell.self, forCellReuseIdentifier: MagazineFamousCell.self.description())
        tableView.register(MagazinePreviewCell.self, forCellReuseIdentifier: MagazinePreviewCell.self.description())
        tableView.rowHeight = UITableView.automaticDimension
        tableView.decelerationRate = .fast
        tableView.estimatedRowHeight = 500
        return tableView
    }()
}

extension MagazineViewController {
    func setUI() {
        view.addSubview(magazineTableView)
        
        magazineTableView.contentInsetAdjustmentBehavior = .never
        magazineTableView.separatorStyle = .none
        
        // MARK: - iOS13에선 어떻게 해결해야 하는가?
        // height에 .leastNonzeroMagnitude주는 것으론 해결이 안됨
        if #available(iOS 15.0, *) {
            magazineTableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        magazineTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension MagazineViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 1 { return UIView(frame: CGRect(x: .zero, y: .zero, width: .zero, height: CGFloat.leastNonzeroMagnitude)) }
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        let titleLabel = UILabel()
        headerView.addSubview(titleLabel)
        
        titleLabel.text = "지난 이야기"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        
        titleLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(20)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 1
        ? 70
        : .leastNonzeroMagnitude
    }
    
}
