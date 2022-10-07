//
//  MagazineViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/05.
//

import UIKit

import RxSwift
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
    let famousSectionHeight = UIScreen.main.bounds.width * (500 / 375.0) * 1.05
    // 섹션마다 다른셀을 주기 위해 rxDataSource사용
    lazy var dataSource = RxTableViewSectionedReloadDataSource<MagazineSection> { [unowned self] dataSource, tableView, indexPath, item in
        
        switch item {
            
        case .MagazineFamousCellItem(let datas):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MagazineFamousCell.self.description(), for: indexPath) as? MagazineFamousCell
            else { return UITableViewCell() }
            cell.bind()
            cell.viewModel.fetchedImageUrls.accept(datas.map { $0.imageUrl })
            cell.setUI()
            cell.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.famousSectionHeight)
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
                owner.headerMarginView.isHidden = inset == 0
            }.disposed(by: disposeBag)
        magazineTableView.rx.contentOffset
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] contentOffset in
                guard let self else { return }
                
                // 96(디자이너 요청 픽셀) - 70(두번째 섹션 헤더 크기)
                let inset: CGFloat = 96 - 70
                
                // 기본 tableView section header로 스크롤시 header 고정은 시켰지만 좀더 아래에 고정시키고 싶어서 사용
                if contentOffset.y > self.famousSectionHeight  - inset {
                    self.magazineTableViewTopInset.onNext(inset)
                } else {
                    self.magazineTableViewTopInset.onNext(0)
                }
                
                // 페이지 네이션
                if contentOffset.y > self.magazineTableView.contentSize.height - self.view.frame.height - 200 {
                    self.viewModel.updateTrigger.accept(1)
                }
                
            }.disposed(by: disposeBag)
        
        
        magazineTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
    
    //function
    @objc
    func didTapHeartButton() {
        
    }
    
    @objc
    func didTapSearchButton() {
        
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        bind()
        magazineTableView.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        navigationController?.navigationBar.isHidden = false
        
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithTransparentBackground()
//        navigationAppearance.
        navigationController?.navigationBar.standardAppearance = navigationAppearance
        navigationController?.navigationBar.tintColor = .white
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(didTapHeartButton)),
            UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: self, action: #selector(didTapSearchButton))
        ]
    
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - UIComponents
    let magazineTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MagazineFamousCell.self, forCellReuseIdentifier: MagazineFamousCell.self.description())
        tableView.register(MagazinePreviewCell.self, forCellReuseIdentifier: MagazinePreviewCell.self.description())
        tableView.rowHeight = UITableView.automaticDimension
        tableView.decelerationRate = .fast
        tableView.estimatedRowHeight = 500
        tableView.showsVerticalScrollIndicator = false
        tableView.clipsToBounds = false
        return tableView
    }()
    let headerMarginView = UIView()
}

extension MagazineViewController {
    
    func setUI() {
        [magazineTableView, headerMarginView].forEach {
            view.addSubview($0)
        }
        
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
        
        headerMarginView.backgroundColor = .systemBackground
        
        headerMarginView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(26)
        }
    }
}

extension MagazineViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 1 { return UIView(frame: CGRect(x: .zero, y: .zero, width: .zero, height: CGFloat.leastNonzeroMagnitude)) }
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        
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
