//
//  JHBPMulticastDelegate.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/12/29.
//

import Foundation

// 🐻‍❄️ NOTE: - Rx Extension으로 처리할 수 있습니다.

protocol JHBPMulticastDelegate {
    typealias type = JHBPContentSectionHeaderView.JHBPContentHeaderButtonType
    
    /*
     🐻‍❄️ NOTE: - 아래 함수들의 네이밍 고민
     함수들의 네이밍 규칙: -> notify + 해당 이벤트를 발생시키는 주체
    */
    
    /** to BPContentSectionHeaderView*/ func notifyContentHeader(indexPath: IndexPath, forType: type)
    /** to notifyToContentCell*/ func notifyContentCell(indexPath: IndexPath?, forType: type)
    /** to notifyToViewController*/ func notifyViewController(offset: CGFloat)
    /** to notifyToCellCollectionViewOffset*/ func notifyCellCollectionView(value: Bool)
}

extension JHBPMulticastDelegate {
    func notifyContentHeader(indexPath: IndexPath, forType: type) { }
    func notifyContentCell(indexPath: IndexPath?, forType: type) { }
    func notifyViewController(offset: CGFloat) { }
    func notifyCellCollectionView(value: Bool) { }
}

// MARK: - Delegating Object
public class JHBPDispatchSystem {
    /*
     🐻‍❄️ NOTE: - 이 부분을 싱글톤 말고 conform하게 해서 사용하게 만들려고 하는데 VC랑 Cell 두곳에서 상속받아야 해서 고민이네요 ㅠ
     Global하게 하는 방법도 있지만 그건 아닌것 같고,, serviceProvier를 만들어 볼 수도 있겠네요!
     아니면 이 부분은 SDK 만들듯이 만드는 방법도 고려해 보겠습니다.
     */
    
    static let dispatch: JHBPDispatchSystem = JHBPDispatchSystem()
    
    private init() { }
    
    let multicastDelegate = MulticastDelegate<JHBPMulticastDelegate>()
}
