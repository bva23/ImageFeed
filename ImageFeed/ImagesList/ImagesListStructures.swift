//
//  ImagesStructure.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 03.08.2023.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String
    let welcomeDescription: String?
    let isLiked: Bool
    let width: Int
    let height: Int
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case createdAt = "created_at"
        case welcomeDescription = "description"
        case isLiked = "liked_by_user"
        case width = "width"
        case height = "height"
        case urls = "urls"
    }
}

struct UrlsResult: Decodable {
    let thumbImageURL: String
    let largeImageURL: String
    
    enum CodingKeys: String, CodingKey {
        case thumbImageURL = "thumb"
        case largeImageURL = "full"
    }
}

struct LikePhotoResult: Codable {
    let photo: LikedPhoto
}

struct LikedPhoto: Codable {
    let id: String
}
