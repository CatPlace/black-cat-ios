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
    }
    
    func bind(reactor: Reactor) {
        dispatch(reactor: reactor)
        render(reactor: reactor)
    }
    
    private func dispatch(reactor: Reactor) {
        
    }
    
    private func render(reactor: Reactor) {
        reactor.state.map { $0.sections }
            .asObservable()
            .bind(to: self.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    // MARK: - UIComponents
    lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.contentInsetAdjustmentBehavior = .never
        
        cv.register(Reusable.thumbnailCell)
        cv.register(Reusable.contentCell)
        
        return cv
    }()
}
