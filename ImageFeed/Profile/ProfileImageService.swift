//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 13.07.2023.
//

import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    
    private (set) var avatarURL: URL?
    private let urlBuilder = URLRequestBuilder.shared
    private var currentTask: URLSessionTask?
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    func fetchProfileImageURL(userName: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let request = makeRequest(userName: userName) else { return }
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let profilePhoto):
                guard let mediumPhoto = profilePhoto.profileImage?.medium else { return }
                self.avatarURL = URL(string: mediumPhoto)
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": mediumPhoto]
                )
            case .failure(let error):
                completion(.failure(error))
            }
            self.currentTask = nil
        }
        self.currentTask = task
        task.resume()
    }
    
    private func makeRequest(userName: String) -> URLRequest? {
        urlBuilder.makeHTTPRequest(path: "/users/\(userName)",
                                   httpMethod: "GET",
                                   baseURLString: Constants.defaultApiBaseURLString
        )
    }
}

struct UserResult: Codable {
    let profileImage: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
