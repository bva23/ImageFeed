//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 03.07.2023.
//

import Foundation

class OAuth2TokenStorage {
    
    private init() {}
    
    static func shared() -> OAuth2TokenStorage {
        return OAuth2TokenStorage()
    }
    
    private let tokenKey = "BearerToken"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}
