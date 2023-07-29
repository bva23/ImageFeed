//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 03.07.2023.
//

import Foundation
import SwiftKeychainWrapper

class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let keychainWrapper = KeychainWrapper.standard
    
    var token: String? {
        get {
            keychainWrapper.string(forKey: Constants.bearerToken)
        }
        set {
            guard let newValue = newValue else { return }
            keychainWrapper.set(newValue, forKey: Constants.bearerToken)
        }
    }
}
