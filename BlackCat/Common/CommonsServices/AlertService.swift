//
//  AlertService.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/05.
//

import UIKit

import RxSwift
import URLNavigator

protocol AlertActionType {
    var title: String? { get }
    var style: UIAlertAction.Style { get }
}

extension AlertActionType {
    var style: UIAlertAction.Style {
        return .default
    }
}

protocol AlertServiceProtocol: AnyObject {
    func show<Action: AlertActionType>(
        title: String?,
        message: String?,
        preferredStyle: UIAlertController.Style,
        actions: [Action]
    ) -> Observable<Action>
}

final class AlertService: AlertServiceProtocol {
    
    func show<Action: AlertActionType>(
        title: String?,
        message: String?,
        preferredStyle: UIAlertController.Style,
        actions: [Action]
    ) -> Observable<Action> {
        return Observable.create { observer in
            let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            for action in actions {
                let alertAction = UIAlertAction(title: action.title, style: action.style) { _ in
                    observer.onNext(action)
                    observer.onCompleted()
                }
                alert.addAction(alertAction)
            }
            Navigator().present(alert)
            return Disposables.create {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
