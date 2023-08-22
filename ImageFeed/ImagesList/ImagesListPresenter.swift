//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 21.08.2023.
//

import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapLike(for cell: ImagesListCell)
}

class ImagesListPresenter: ImagesListPresenterProtocol {
    private weak var view: ImagesListViewControllerProtocol?
    private let imagesListService: ImagesListServiceProtocol
    private var imagesListServiceObserver: NSObjectProtocol?
    
    init(view: ImagesListViewControllerProtocol,
         imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.view = view
        self.imagesListService = imagesListService
    }
    
    func viewDidLoad() {
        imagesListService.fetchPhotosNextPage()
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateTableViewAnimated()
        }
    }
    
    func updateTableViewAnimated() {
        guard let view = view else { return }
        let oldCount = view.photos.count
        let newCount = imagesListService.photos.count
        if oldCount != newCount {
            view.photos = imagesListService.photos
            let indexPaths = (oldCount..<newCount).map { index in
                IndexPath(row: index, section: 0)
            }
            view.performBatchUpdate(with: indexPaths)
        }
    }
    
    func didTapLike(for cell: ImagesListCell) {
        guard let indexPath = view?.indexPath(for: cell) else { return }
        var photo = imagesListService.photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success():
                photo.isLiked = !photo.isLiked
                cell.setIsLiked(isLiked: imagesListService.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                view?.showLikeError(error)
            }
        }
    }
}
