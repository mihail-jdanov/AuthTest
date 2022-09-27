//
//  NetworkManager.swift
//  AuthTest
//
//  Created by Михаил Жданов on 24.09.2022.
//

import Foundation

class NetworkManager: NSObject {
    
    private let authUrl = URL(string: "https://smart.eltex-co.ru:8273/api/v1/oauth/token")
    
    private let defaultError = NSError(
        domain: "",
        code: 0,
        userInfo: ["NSLocalizedDescription": "Неверный логин или пароль."]
    )
    
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
            if let dict = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any],
               let accessToken = dict["access_token"] as? String, let refreshToken = dict["refresh_token"] as? String {
                let authData = AuthData(accessToken: accessToken, refreshToken: refreshToken)
                KeychainHelper.shared.save(authData, service: .defaultKeychainService, account: .defaultKeychainAccount)
                completion?(nil)
            } else {
                completion?(error ?? self.defaultError)
            }
        }.resume()
    }
    
    func fetchUserInfo() {
        
    }
    
}

extension NetworkManager: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
}
