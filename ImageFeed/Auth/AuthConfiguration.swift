//
//  Constants.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 29.05.2023.
//

import UIKit

enum Constants {
    static let DefaultBaseURL = "https://api.unsplash.com"
    static let BaseURLString = "https://unsplash.com"
    static let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let BaseAuthTokenPath = "/oauth/token"
    static let AccessKey = "MnJNOUZX45XldCEjcxqqKhuVvQ64Hz0AUqO7s2uLy-c"
    static let SecretKey = "xIZySRjd5etR7dO8m8GaNZ1rgH3E9cab84UJvGAsEg4"
    static let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let AccessScope = "public+read_user+write_likes"
    static let BearerToken = "bearerToken"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: String
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.AccessKey,
                                 secretKey: Constants.SecretKey,
                                 redirectURI: Constants.RedirectURI,
                                 accessScope: Constants.AccessScope,
                                 authURLString: Constants.UnsplashAuthorizeURLString,
                                 defaultBaseURL: Constants.DefaultBaseURL)
    }
}
