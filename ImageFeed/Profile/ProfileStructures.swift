//
//  ProfileStructures.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 21.07.2023.
//

import Foundation

struct ProfileResult: Codable {
    let userLogin: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    let profileImage: ProfileImage?
    
    private enum CodingKeys: String, CodingKey {
        case userLogin = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String?
    let medium: String?
    let large: String?
}

struct Profile: Codable {
    let username: String
    let name: String?
    let loginName: String
    let bio: String?
}

extension Profile {
    init(result profile: ProfileResult) {
        self.init(
            username: profile.userLogin,
            name: "\(profile.firstName ?? "") \(profile.lastName ?? "")",
            loginName: "@\(profile.userLogin)",
            bio: profile.bio
        )
    }
}
