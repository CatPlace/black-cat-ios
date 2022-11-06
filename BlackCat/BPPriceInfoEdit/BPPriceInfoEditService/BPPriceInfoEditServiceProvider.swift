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
}

final class BPPriceInfoEditService: BPPriceInfoEditServiceProtocol {
    lazy var alertService: AlertServiceProtocol = AlertService()
}
