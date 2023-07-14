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
    // var profile: Profile?
    private(set) var profile: Profile?
/*
    init(task: URLSessionTask? = nil, urlSession: URLSession = URLSession.shared, profile: Profile?) {
        self.task = task
        self.urlSession = urlSession
        self.profile = profile
    }
*/

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        var profileRequest: URLRequest {
            URLRequest.makeHTTPRequest(path: "/me", httpMethod: "GET")
        }
        
        task = urlSession.objectTask(for: profileRequest) { [weak self] (result: Result<ProfileResult, Error>) in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let body):
                    let profile = Profile(username: body.username, name: "\(String(describing: body.firstName)) \(String(describing: body.lastName))", loginName: "@\(body.username)", bio: body.bio)
                    
                    completion(.success(profile))
                    self.task = nil
                case .failure(let error):
                    print(error)
                    completion(.failure(error))
                    self.task = nil
                }
            }
        }
        task?.resume()
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
struct Profile {
    let username: String
    let name: String?
    let loginName: String
    let bio: String?
}
