//
//  BPProfileEditServiceProvider.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/05.
//

import UIKit
import RxSwift

protocol BPPriceInfoEditServiceProtocol {
    var alertService: AlertServiceProtocol { get }
    var priceEditStringService: BPPriceInfoEditStringServiceProtocol { get set }
}

final class BPPriceInfoEditService: BPPriceInfoEditServiceProtocol {
    lazy var alertService: AlertServiceProtocol = AlertService()
    lazy var priceEditStringService: BPPriceInfoEditStringServiceProtocol = BPPriceInfoEditStringService()
}
