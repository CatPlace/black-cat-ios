//
//  BPPriceInfoEditReactor.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/05.
//

import UIKit
import ReactorKit

final class BPPriceInfoEditReactor: Reactor {
    enum Action {
        case didTapCloseItem
        case didTapPhotoItem
        case didTapConfirmItem(String)
        case appendImage(UIImage)
//        case updateDataSource(BPPriceInfoEditModel)
    }
    
    enum Mutation {
        case isDismiss
        case openPhotoLibrary
        case sendProfile(String)
        
        case appendImage(UIImage)
    }
    
    struct State {
        var isDismiss = false
        @Pulse var isOpenPhotoLibrary = false
        
        @Pulse var sections: [BPPriceInfoEditCellSection] {
            didSet { print("🧞‍♂️ sections \(sections)")}
        }
        
        init(sections: [BPPriceInfoEditCellSection]) {
            self.sections = sections
        }
    }
    
    var initialState: State
    var provider: BPPriceInfoEditServiceProtocol
    
    init(provider: BPPriceInfoEditServiceProtocol = BPPriceInfoEditService()) {
        self.provider = provider
        self.initialState = State(sections: BPPriceInfoEditReactor.confugurationSections())
        
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTapCloseItem:
            return .just(.isDismiss)
        case .didTapPhotoItem:
            return .just(.openPhotoLibrary)
        case .didTapConfirmItem(let string):
//            provider.priceEditStringService.convertToArray(string)
            return .just(.sendProfile(string))
        case .appendImage(let image):
            return .just(.appendImage(image))
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
            currentState.sections.forEach { section in
                print("👨🏼‍🚀 \(section)")
            }
            return newState
        case .appendImage(let image):
            var newValue = appendImage(image: image)
            newState.sections = newValue
            
            return newState
        }
    }
    
    func appendImage(image: UIImage) -> [BPPriceInfoEditCellSection] {
        var oldValue = currentState.sections
        let imageCell = BPPriceInfoEditSectionsFactory.makeImageCell(
            .init(row: 0, type: .image, image: image))
        let textCell = BPPriceInfoEditSectionsFactory.makeTextCell(
            .init(row: 0, type: .text, input: "이거처음줄")
        )
        
//        let imageSection = BPPriceInfoEditCellSection.imageCell([imageCell])
//        let textSection = BPPriceInfoEditCellSection.textCell([textCell])
        let mergeSection = BPPriceInfoEditCellSection.imageCell([imageCell, textCell])
        return oldValue + [mergeSection]
    }
}

extension BPPriceInfoEditReactor {
    static func confugurationSections() -> [BPPriceInfoEditCellSection] {
        let textCell = BPPriceInfoEditSectionsFactory.makeTextCell(
            .init(row: 0, type: .text, input: "이거처음줄")
        )

        let textCellSection = BPPriceInfoEditCellSection.textCell([textCell])
        
        return [textCellSection]
    }
}
