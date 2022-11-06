//
//  BPProfileEditServiceProvider.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/05.
//

import UIKit
import RxSwift

protocol BPProfileEditServiceProtocol {
    var alertService: AlertServiceProtocol { get }
}

final class BPProfileEditServiceProvider: BPProfileEditServiceProtocol {
    lazy var alertService: AlertServiceProtocol = AlertService()
}
