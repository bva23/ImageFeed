//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 03.08.2023.
//

import Foundation

protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}

final class ImagesListService: ImagesListServiceProtocol {
    static let shared = ImagesListService()
    private init() {}
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int = 0
    private var task: URLSessionTask?
    private var token: String? {
        OAuth2TokenStorage.shared.token
    }
    
    private let urlBuilder = URLRequestBuilder.shared
    private let urlSession = URLSession.shared
    private let dateFormatter = ISO8601DateFormatter()
    
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        if task != nil {
            task?.cancel()
        }
        
        guard task == nil, let token = token else { return }
        let nextPage = lastLoadedPage + 1
        let request = photosRequest(token: token, page: nextPage, perPage: 10)
        let task = urlSession.objectTask(for: request!) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let body):
                DispatchQueue.main.async {
                    let newPhotos = self.convert(photoResult: body)
                    self.photos.append(contentsOf: newPhotos)
                    NotificationCenter.default.post(name: ImagesListService.DidChangeNotification,
                                                    object: self)
                    self.lastLoadedPage += 1
                }
            case .failure(let error):
                assertionFailure(error.localizedDescription)
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    private func convert(photoResult: [PhotoResult]) -> [Photo] {
        return photoResult.map {
            Photo(id: $0.id,
                  size: CGSize(width: $0.width, height: $0.height),
                  createdAt: dateFormatter.date(from: $0.createdAt),
                  welcomeDescription: $0.welcomeDescription,
                  thumbImageURL: $0.urls.thumbImageURL,
                  largeImageURL: $0.urls.largeImageURL,
                  isLiked: $0.isLiked)
        }
    }
    
    func photosRequest(token: String, page: Int, perPage: Int) -> URLRequest? {
        var request = urlBuilder.makeHTTPRequest(
            path: "/photos?"
            + "page=\(page)"
            + "&&per_page=\(perPage)",
            httpMethod: "GET",
            baseURLString: Constants.DefaultBaseURL
        )
        request?.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let token = OAuth2TokenStorage.shared.token else { return }
        
        guard var request = likeRequest(token: token, photoId: photoId, isLike: isLike) else { return }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<LikePhotoResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success:
                if let index = photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked)
                    self.photos[index] = newPhoto
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
        
        
        func likeRequest(token: String, photoId: String, isLike: Bool) -> URLRequest? {
            var request = urlBuilder.makeHTTPRequest(
                path: "/photos/\(photoId)/like",
                httpMethod: isLike ? "POST" : "DELETE",
                baseURLString: Constants.DefaultBaseURL
            )
            request?.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        }
    }
}
