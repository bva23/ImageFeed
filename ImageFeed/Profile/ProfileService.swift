//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 07.07.2023.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private var currentTask: URLSessionTask?
    private let builder: URLRequestBuilder
    var urlSession = URLSession.shared
    private(set) var profile: Profile?
    
    init(builder: URLRequestBuilder = .shared) {
        self.builder = builder
    }
    
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        currentTask?.cancel()
        
        
        guard let request = makeFetchProfileRequest() else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let session = URLSession.shared
        
        currentTask = session.objectTask(for: request) {
            [weak self] (response: Result<ProfileResult, Error>) in
            self?.currentTask = nil
            switch response {
            case .success(let profileResult):
                let profile = Profile(result: profileResult)
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    private func makeFetchProfileRequest() -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/me",
            httpMethod: "GET",
            baseURLString: Constants.defaultApiBaseURLString
        )
    }
}

