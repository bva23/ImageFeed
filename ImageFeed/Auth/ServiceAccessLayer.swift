//
//  ServiceAccessLayer.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 03.06.2023.
//

import Foundation

final class OAuth2Service {
    
    private init() {}
    
    static func shared() -> OAuth2Service {
        return OAuth2Service()
    }
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private var tokenStorage = OAuth2TokenStorage.shared()
    private (set) var authToken: String? {
        get {
            return tokenStorage.token
        }
        set {
            tokenStorage.token = newValue
        } }
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                return
            }
        } else {
            if lastCode == code {
                return
            }
        }
        lastCode = code
        let request = makeRequest(code: code)
        let task = urlSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                completion(.success("\(String(describing: self.authToken))"))
                self.task = nil
                if error != nil {
                    self.lastCode = nil
                }
            }
        }
        self.task = task
        task.resume()
    }
    private func makeRequest(code: String) -> URLRequest {
        guard let url = URL(string: "...\(code)") else { fatalError("Failed to create URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }

private func object(
    for request: URLRequest,
    completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
) -> URLSessionTask {
    let decoder = JSONDecoder()
    return urlSession.data(for: request) { (result: Result<Data, Error>) in
        let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
            Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
        }
        completion(response)
    }
}
private func authTokenRequest(code: String) -> URLRequest {
    URLRequest.makeHTTPRequest(
        path: "/oauth/token"
        + "?client_id=\(accessKey)"
        + "&&client_secret=\(secretKey)"
        + "&&redirect_uri=\(redirectUri)"
        + "&&code=\(code)"
        + "&&grant_type=authorization_code",
        httpMethod: "POST",
        baseURL: URL(string: "https://unsplash.com")!
    ) }
private struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}
}
// MARK: - HTTP Request
extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL = defaultBaseUrl
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        request.httpMethod = httpMethod
        return request
    } }
// MARK: - Network Connection
enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}
extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletion: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletion(.success(data))
                } else {
                    fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletion(.failure(NetworkError.urlSessionError))
            }
        })
        task.resume()
        return task
    }
    
    func profileTask<Task: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<Task, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    let error = NetworkError.urlSessionError
                    completion(.failure(error))
                    return
                }
                
                let statusCode = httpResponse.statusCode
                guard 200..<300 ~= statusCode else {
                    let error = NetworkError.httpStatusCode(statusCode)
                    completion(.failure(error))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(Task.self, from: data!)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        return task
    }
}
