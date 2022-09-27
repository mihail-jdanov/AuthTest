//
//  UIAlertController.swift
//  AuthTest
//
//  Created by Михаил Жданов on 28.09.2022.
//

import UIKit

extension UIAlertController {
    
    static func presentErrorAlert(_ error: Error, retryHandler: (() -> Void)?, closeHandler: (() -> Void)?) {
        let alertController = UIAlertController(
            title: "Ошибка",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { action in
            retryHandler?()
        }
        let closeAction = UIAlertAction(title: "Закрыть", style: .cancel) { action in
            closeHandler?()
        }
        if retryHandler != nil { alertController.addAction(retryAction) }
        if closeHandler != nil { alertController.addAction(closeAction) }
        alertController.preferredAction = alertController.actions.first
        UIViewController.topViewController()?.present(alertController, animated: true, completion: nil)
    }
    
}
