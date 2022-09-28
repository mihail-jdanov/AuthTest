//
//  UserData.swift
//  AuthTest
//
//  Created by Михаил Жданов on 28.09.2022.
//

import Foundation

struct UserData: Codable {
    
    let roleId: String
    let username: String
    let email: String?
    let permissions: [String]
    
}
