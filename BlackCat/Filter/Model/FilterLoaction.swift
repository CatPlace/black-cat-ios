//
//  FilterLoaction.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/16.
//

import Foundation
import RealmSwift

public class FilterLocation: Object {
    
    // ✏️ NOTE: - 지역이 늘어나면 "_" replace "/" 자동화 필요.
    public enum LocationType: String, CaseIterable {
        case 서울 = "서울"
        case 경기_인천 = "경기/인천"
        case 충청_대전 = "충천/대전"
        case 전라_광주 = "전라/광주"
        case 경북_대구 = "경북/대구"
        case 경남_부산_울산 = "경남/부산/울산"
        case 강원 = "강원"
        case 제주 = "제주"
    }

    @Persisted(primaryKey: true) private var typeString: String
    
    public private(set) var type: LocationType {
        get { return LocationType(rawValue: typeString) ?? .서울 }
        set { typeString = newValue.rawValue }
    }
    @Persisted public var isSubscribe: Bool
    
    convenience init(type: LocationType, isSubscribe: Bool = false) {
        self.init()
        
        self.type = type
    }
}
