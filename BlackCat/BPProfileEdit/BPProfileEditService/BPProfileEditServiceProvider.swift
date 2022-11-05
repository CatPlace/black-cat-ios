//
//  BPProfileEditServiceProvider.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/05.
//

import UIKit
import RxSwift

protocol BPProfileEditServiceProtocol {
    
}

final class BPProfileEditServiceProvider: BPProfileEditServiceProtocol {
    
}

protocol AlertServiceProtocol {
    
}

extension UIViewController {
    //MARK: 어떤 액션을 선택했는지 알기위함
    enum ActionType {
        case ok
        case cancel
    }
    
    // 하나의 액션을 표시하는 alert wrapping
    func showAlert(title : String, message: String? = nil) -> Observable<ActionType> {
        
        return Observable.create { [weak self] observer in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                // event 전달
                observer.onNext(.ok)
                observer.onCompleted()
            }
            alertController.addAction(okAction)
            
            self?.present(alertController, animated: true, completion: nil)
            
            return Disposables.create {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
        
    }
}
