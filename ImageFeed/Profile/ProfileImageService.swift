//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 13.07.2023.
//

import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void)
}

struct UserResult: Codable {
    let profileImage: [String:String]
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
