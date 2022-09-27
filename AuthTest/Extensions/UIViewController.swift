//
//  UIViewController.swift
//  AuthTest
//
//  Created by Михаил Жданов on 28.09.2022.
//

import UIKit

extension UIViewController {
    
    static func topViewController(baseVC: UIViewController? =
                                  UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navController = baseVC as? UINavigationController {
            return topViewController(baseVC: navController.visibleViewController)
        }
        if let tabBarController = baseVC as? UITabBarController {
            if let selectedVC = tabBarController.selectedViewController {
                return topViewController(baseVC: selectedVC)
            }
        }
        if let presentedVC = baseVC?.presentedViewController {
            return topViewController(baseVC: presentedVC)
        }
        return baseVC
    }
    
}
