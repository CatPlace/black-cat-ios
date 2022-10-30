//
//  BusinessProfileViewController.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import RxDataSources
import BlackCatSDK

final class BusinessProfileViewController: UIViewController, View {
    typealias Reactor = BusinessProfileReactor
    typealias ManageMentDataSource = RxCollectionViewSectionedAnimatedDataSource<BusinessProfileCellSection>
    
    enum Reusable {
        static let thumbnailCell = ReusableCell<BPThumbnailImageCell>()
        static let contentCell = ReusableCell<BPContentCell>()
        static let contentHeaderView = ReusableView<BPContentSectionHeaderView>()
    }
    
    var disposeBag: DisposeBag = DisposeBag()
    let dataSource: ManageMentDataSource = ManageMentDataSource { _, collectionView, indexPath, items in
        switch items {
        case .thumbnailImageItem(let reactor):
            let cell = collectionView.dequeue(Reusable.thumbnailCell, for: indexPath)
            
            cell.reactor = reactor
            return cell
        case .contentItem(let reactor):
            let cell = collectionView.dequeue(Reusable.contentCell, for: indexPath)
            
            cell.reactor = reactor
            return cell
        }
    } configureSupplementaryView: { _, collectionView, kind, indexPath -> UICollectionReusableView in
        
        switch indexPath.section {
        case 0: return UICollectionReusableView()
        case 1:
            var contentHeaderView = collectionView.dequeue(Reusable.contentHeaderView, kind: .header, for: indexPath)
            contentHeaderView.reactor = BPContentSectionHeaderReactor(initialState: .init())
            return contentHeaderView
        default: return UICollectionReusableView()
        }
    }
    
    func bind(reactor: Reactor) {
        dispatch(reactor: reactor)
        render(reactor: reactor)
    }
    
    private func dispatch(reactor: Reactor) {
        collectionView.rx.didEndDisplayingCell
            .withLatestFrom(collectionView.rx.willDisplayCell) { didEnd, will -> (IndexPath, IndexPath) in
                return (didEnd.at, will.at)
            }
            .filter { didEnd, will in return (didEnd != will) && (didEnd.section != 0) }
            .map { didEnd, will in return will }
            .bind { indexPath in
                var type: BPContentSectionHeaderView.BPContentHeaderButtonType
                
                switch indexPath.row {
                case 0: type = .profile
                case 1: type = .product
                case 2: type = .review
                case 3: type = .info
                default: type = .profile
                }

//                dispatch.multicastDelegate.invokeDelegates { delegate in
//                    delegate.notifyHeader(indexPath: indexPath, forType: type)
//                }
            }.disposed(by: disposeBag)
    }
    
    private func render(reactor: Reactor) {
        reactor.state.map { $0.sections }
            .bind(to: self.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    // MARK: Initialize
    init(reactor: Reactor = Reactor(initialState: .init())) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        BPDispatchSystem.dispatch.multicastDelegate.addDelegate(self)
    }
    
    // MARK: - UIComponents
    lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.contentInsetAdjustmentBehavior = .never
        
        cv.register(Reusable.thumbnailCell)
        cv.register(Reusable.contentCell)
        cv.register(Reusable.contentHeaderView, kind: .header)
        
        return cv
    }()
}
