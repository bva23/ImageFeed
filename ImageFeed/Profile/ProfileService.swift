//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 07.07.2023.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    
    var task: URLSessionTask?
    var urlSession = URLSession.shared
    private(set) var profile: Profile?

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        let request = makeRequest(token: token)
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let decodedObject):
                let profile = Profile(decodedData: decodedObject)
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeRequest(token: String) -> URLRequest {
        guard let url = URL(string: "\(defaultBaseUrl)" + "/me") else { fatalError("Failed to create URL") }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}
struct Profile: Codable {
    let username: String
    let name: String?
    let loginName: String
    let bio: String?
    
    init(decodedData: ProfileResult) {
        self.username = decodedData.username
        self.name = (decodedData.firstName ?? "") + " " + (decodedData.lastName ?? "")
        self.loginName = "@" + (decodedData.username )
        self.bio = decodedData.bio
    }
}
