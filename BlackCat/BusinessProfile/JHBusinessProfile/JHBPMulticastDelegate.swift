//
//  JHBPMulticastDelegate.swift
//  BlackCat
//
//  Created by ๊น์งํ on 2022/12/29.
//

import Foundation

// ๐ปโโ๏ธ NOTE: - Rx Extension์ผ๋ก ์ฒ๋ฆฌํ  ์ ์์ต๋๋ค.

protocol JHBPMulticastDelegate {
    typealias type = JHBPContentSectionHeaderView.JHBPContentHeaderButtonType
    
    /*
     ๐ปโโ๏ธ NOTE: - ์๋ ํจ์๋ค์ ๋ค์ด๋ฐ ๊ณ ๋ฏผ
     ํจ์๋ค์ ๋ค์ด๋ฐ ๊ท์น: -> notify + ํด๋น ์ด๋ฒคํธ๋ฅผ ๋ฐ์์ํค๋ ์ฃผ์ฒด
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
     ๐ปโโ๏ธ NOTE: - ์ด ๋ถ๋ถ์ ์ฑ๊ธํค ๋ง๊ณ  conformํ๊ฒ ํด์ ์ฌ์ฉํ๊ฒ ๋ง๋ค๋ ค๊ณ  ํ๋๋ฐ VC๋ Cell ๋๊ณณ์์ ์์๋ฐ์์ผ ํด์ ๊ณ ๋ฏผ์ด๋ค์ ใ 
     Globalํ๊ฒ ํ๋ ๋ฐฉ๋ฒ๋ ์์ง๋ง ๊ทธ๊ฑด ์๋๊ฒ ๊ฐ๊ณ ,, serviceProvier๋ฅผ ๋ง๋ค์ด ๋ณผ ์๋ ์๊ฒ ๋ค์!
     ์๋๋ฉด ์ด ๋ถ๋ถ์ SDK ๋ง๋ค๋ฏ์ด ๋ง๋๋ ๋ฐฉ๋ฒ๋ ๊ณ ๋ คํด ๋ณด๊ฒ ์ต๋๋ค.
     */
    
    static let dispatch: JHBPDispatchSystem = JHBPDispatchSystem()
    
    private init() { }
    
    let multicastDelegate = MulticastDelegate<JHBPMulticastDelegate>()
}
