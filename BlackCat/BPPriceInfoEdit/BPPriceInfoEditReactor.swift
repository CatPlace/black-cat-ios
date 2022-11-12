//
//  BPPriceInfoEditReactor.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/05.
//

import UIKit
import RxRelay
import ReactorKit

final class BPPriceInfoEditReactor: Reactor {
    enum Action {
        case didTapCloseItem
        case didTapPhotoItem
        case didTapConfirmItem(String)
        case appendImage(UIImage)
        case updateDatasource((IndexPath, String))
    }
    
    enum Mutation {
        case isDismiss
        case openPhotoLibrary
        case sendProfile(String)
        
        case appendImage(UIImage)
        case updateDatasource((IndexPath, String))
    }
    
    struct State {
        var isDismiss = false
        @Pulse var isOpenPhotoLibrary = false
        
        var sections: BehaviorRelay<[BPPriceInfoEditCellViewModel]> {
            didSet { print("👽 \(sections)") }
        }
        
        init(sections: BehaviorRelay<[BPPriceInfoEditCellViewModel]>) {
            self.sections = sections
        }
    }
    
    var initialState: State
    var provider: BPPriceInfoEditServiceProtocol
    
    init(provider: BPPriceInfoEditServiceProtocol = BPPriceInfoEditService()) {
        self.provider = provider
        //  🐻‍❄️ NOTE: - 외부에서 초기값을 주입 받을 수 있도록 (Why? -> 수정해야 하니까요!)
        self.initialState = .init(sections: .init(value: [.init(
            editModelRelay: .init(
                value: .init(
                    row: 0,
                    type: .text,
                    input: "샘플의 처음값"
                )
            )
        )]))
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTapCloseItem:
            return .just(.isDismiss)
        case .didTapPhotoItem:
            return .just(.openPhotoLibrary)
        case .didTapConfirmItem(let string):

            return .just(.sendProfile(string))
        case .appendImage(let image):
            return .just(.appendImage(image))
        case let .updateDatasource(data):
            return .just(.updateDatasource(data))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .isDismiss:
            newState.isDismiss = true
            return newState
        case .openPhotoLibrary:
            newState.isOpenPhotoLibrary = true
            return newState
        case .sendProfile(let string):
            // NOTE: - 서버로 보내기
            
            return newState
        case .appendImage(let image):
            let result = appendImage(to: image)
            newState.sections.accept(result)
            
            return newState
        case let .updateDatasource((indexPath, text)):
            
            return newState
        }
    }
    
    private func appendImage(to image: UIImage) -> [BPPriceInfoEditCellViewModel] {
        // MARK: - 셀추가
        let imageModel = BPPriceInfoEditModel(row: 0, type: .image, image: image)
        let textModel = BPPriceInfoEditModel(row: 0, type: .text, input: "image다음")
        
        var oldValue = currentState.sections.value
        
        oldValue.append(.init(editModelRelay: .init(value: imageModel)))
        oldValue.append(.init(editModelRelay: .init(value: textModel)))
        
        return oldValue
    }
}
