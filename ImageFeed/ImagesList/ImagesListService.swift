//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 03.08.2023.
//

import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    
    private let urlBuilder = URLRequestBuilder.shared
    private let urlSession = URLSession.shared
    private let dateFormatter = ISO8601DateFormatter()
    
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if task != nil {
            task?.cancel()
        }
        
        let nextPage = lastLoadedPage == nil
        ? 1
        : lastLoadedPage! + 1
        
        guard let token = OAuth2TokenStorage.shared.token else { return }
        
        var request = photosRequest(token: token, page: nextPage, perPage: 10)!
        
        let task = URLSession.shared.objectTask(for: request ) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.task = nil
                switch result {
                case .success(let photosResults):
                    photosResults.forEach { image in
                        let date = self.dateFormatter.date(from: image.createdAt ?? "")
                        guard let thumbImage = image.urls?.thumbImageURL,
                              let fullImage = image.urls?.largeImageURL else { return }
                        self.photos.append(Photo(id: image.id,
                                                 size: CGSize(width: image.width ?? 0, height: image.height ?? 0),
                                                 createdAt: date,
                                                 welcomeDescription: image.welcomeDescription,
                                                 thumbImageURL: thumbImage,
                                                 largeImageURL: fullImage,
                                                 isLiked: image.isLiked ?? false))
                    }
                    NotificationCenter.default.post(name: ImagesListService.DidChangeNotification,
                                                    object: self,
                                                    userInfo: ["Images": self.photos])
                    self.lastLoadedPage = nextPage
                case .failure(let error):
                    assertionFailure("Ошибка загрузки изображения \(error)")
                }
            }
        }
        self.task = task
        task.resume()
        
        func photosRequest(token: String, page: Int, perPage: Int) -> URLRequest? {
            var request = urlBuilder.makeHTTPRequest(
                path: "/photos?"
                + "page=\(page)"
                + "&&per_page=\(perPage)",
                httpMethod: "GET",
                baseURLString: Constants.defaultApiBaseURLString
            )
            request?.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        }
    }
}
