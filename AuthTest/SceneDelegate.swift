//
//  SceneDelegate.swift
//  AuthTest
//
//  Created by Михаил Жданов on 22.09.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
//        KeychainHelper.shared.delete(service: .defaultKeychainService, account: .defaultKeychainAccount)
        if let _ = KeychainHelper.shared.read(
            service: .defaultKeychainService,
            account: .defaultKeychainAccount,
            type: AuthData.self
        ) {
            window.rootViewController = UserInfoViewController()
        } else {
            window.rootViewController = AuthViewController()
        }
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }

}

