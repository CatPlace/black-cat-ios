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
        
        @Pulse var sections: [BPPriceInfoEditCellViewModel] {
            didSet { print("🧞‍♂️ sections \(sections)")}
        }
        
        @Pulse var sampleSections = BehaviorRelay<[BPPriceInfoEditCellViewModel]>(
            value: [.init(editModelRelay: .init(value: .init(row: 0, type: .text, input: "샘플의 처음값")))]
        ) { didSet { print("👽 \(sampleSections)") } }
        
        init(sections: [BPPriceInfoEditCellViewModel]) {
            self.sections = sections
        }
    }
    
    var initialState: State
    var provider: BPPriceInfoEditServiceProtocol
    
    init(provider: BPPriceInfoEditServiceProtocol = BPPriceInfoEditService()) {
        self.provider = provider
        self.initialState = State(sections: [.init(editModelRelay: .init(value: .init(row: 0, type: .text, input: "처음입니당.")))])
        
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
            currentState.sections.forEach { section in
                print("👨🏼‍🚀 \(section)")
            }
            return newState
        case .appendImage(let image):
//            var newValue = currentState.sampleSections
//            let imageModel = BPPriceInfoEditModel(row: 0, type: .image, image: image)
//            let textModel = BPPriceInfoEditModel(row: 0, type: .text, input: "image다음")
//
//            var oldValue = currentState.sampleSections.value
////            newValue.accept(oldValue)
//            newState.sampleSections.accept(
//                oldValue +
//                [
//                    .init(editModelRelay: .init(value: imageModel)),
//                    .init(editModelRelay: .init(value: textModel)),
//                ]
//            )
            
            print("포토아이템 들어왔어요.")
//            newState.$sampleSections
//            newState.sampleSections.accept([.init(editModelRelay: .init(value: .init(row: 0, type: .image, image: image)))])
//
//            newState.sampleSections.accept(<#T##event: [BPPriceInfoEditCellViewModel]##[BPPriceInfoEditCellViewModel]#>)
            
            return newState
        case let .updateDatasource((indexPath, text)):
            
            return newState
        }
    }
    
//    func appendImage(image: UIImage) -> [BPPriceInfoEditCellSection] {
//        let imageCell = BPPriceInfoEditSectionsFactory.makeImageCell(
//            .init(row: 0, type: .image, image: image))
//        let textCell = BPPriceInfoEditSectionsFactory.makeTextCell(
//            .init(row: 0, type: .text, input: "이거처음줄")
//        )
//
//        let mergeSection = BPPriceInfoEditCellSection.imageCell([imageCell, textCell])
//        return currentState.sections + [mergeSection]
//    }
}
