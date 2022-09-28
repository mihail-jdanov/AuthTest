//
//  NetworkManager.swift
//  AuthTest
//
//  Created by Михаил Жданов on 24.09.2022.
//

import Foundation

class NetworkManager: NSObject {
    
    private(set) var lastUserData: UserData? {
        get {
            guard let data = UserDefaults.standard.value(forKey: "lastUserData") as? Data else { return nil }
            return try? PropertyListDecoder().decode(UserData.self, from: data)
        }
        set {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: "lastUserData")
        }
    }
    
    private let authUrl = URL(string: "https://smart.eltex-co.ru:8273/api/v1/oauth/token")
    private let userInfoUrl = URL(string: "https://smart.eltex-co.ru:8273/api/v1/user")
    
    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    func authorize(username: String, password: String, completion: ((Error?) -> Void)?) {
        guard let url = authUrl else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let encodedString = ("ios-client:password").data(using: .utf8)?.base64EncodedString() ?? ""
        request.addValue("Basic " + encodedString, forHTTPHeaderField: "Authorization")
        let parameters = "grant_type=password&username=\(username)&password=\(password)"
        request.httpBody = parameters.data(using: .utf8)
        urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let data = data, let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let accessToken = dict["access_token"] as? String, let refreshToken = dict["refresh_token"] as? String {
                let authData = AuthData(accessToken: accessToken, refreshToken: refreshToken)
                KeychainHelper.shared.save(authData, service: .defaultKeychainService, account: .defaultKeychainAccount)
                completion?(nil)
            } else {
                let defaultError = self.generateError(withLocalizedDescription: "Неверный логин или пароль.")
                completion?(error ?? defaultError)
            }
        }.resume()
    }
    
    func fetchUserInfo(completion: ((Error?, UserData?) -> Void)?) {
        let authData = KeychainHelper.shared.read(
            service: .defaultKeychainService,
            account: .defaultKeychainAccount,
            type: AuthData.self
        )
        guard let accessToken = authData?.accessToken, let url = userInfoUrl else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let data = data, let userData = try? JSONDecoder().decode(UserData.self, from: data) {
                self.lastUserData = userData
                completion?(nil, userData)
            } else {
                let defaultError = self.generateError(withLocalizedDescription: "Не удалось получить данные пользователя.")
                completion?(error ?? defaultError, nil)
            }
        }.resume()
    }
    
    private func generateError(withLocalizedDescription description: String) -> NSError {
        return NSError(
            domain: "",
            code: 0,
            userInfo: ["NSLocalizedDescription": description]
        )
    }
    
}

extension NetworkManager: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
}
