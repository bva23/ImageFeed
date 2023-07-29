//
//  Constants.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 29.05.2023.
//

import UIKit

enum Constants {
    static let defaultApiBaseURLString = "https://api.unsplash.com"
    static let baseURLString = "https://unsplash.com"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let baseAuthTokenPath = "/oauth/token"
    
    static let accessKey = "MnJNOUZX45XldCEjcxqqKhuVvQ64Hz0AUqO7s2uLy-c"
    static let secretKey = "xIZySRjd5etR7dO8m8GaNZ1rgH3E9cab84UJvGAsEg4"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let bearerToken = "bearerToken"
}
