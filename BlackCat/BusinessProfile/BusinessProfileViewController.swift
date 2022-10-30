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
            
            // 🐻‍❄️ NOTE: - reactor를 장착해야 합나다.
            return cell
        case .contentItem(let reactor):
            let cell = collectionView.dequeue(Reusable.contentCell, for: indexPath)
            
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

final class BusinessProfileReactor: Reactor {
    enum Action {
        case viewDidLoad
    }
    
    enum Mutation {
        case fetchSection
    }
    
    struct State {
        var sections: [BusinessProfileItem]
        
        init(sections: [BusinessProfileItem]) {
            self.sections = sections
        }
    }
    
    var initialState: State
    
    init(initialState: State) {
        self.initialState = initialState
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .just(.fetchSection)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .fetchSection:
            newState.sections = []
            return newState
        }
    }
}
