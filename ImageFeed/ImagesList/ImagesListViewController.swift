//
//  ViewController.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 29.04.2023.
//

import UIKit
import Kingfisher
import ProgressHUD

protocol ImagesListViewControllerProtocol: AnyObject {
    var photos: [Photo] { get set }
    func indexPath(for cell: ImagesListCell) -> IndexPath?
    func performBatchUpdate(with indexPaths: [IndexPath])
    func showLikeError(_ error: Error)
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private let imagesListService = ImagesListService.shared
    
    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    private let placeholderImage = UIImage(named: "stub")
    
    var presenter: ImagesListPresenterProtocol?
    var photos: [Photo] = []
    private var imagesListServiceObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter = ImagesListPresenter(view: self)
        presenter?.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else { return }
            let largeImageUrlString = photos[indexPath.row].largeImageURL
            let largeImageUrl = URL(string: largeImageUrlString)
            viewController.imageUrl = largeImageUrl
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func indexPath(for cell: ImagesListCell) -> IndexPath? {
        return tableView.indexPath(for: cell)
    }
    
    func performBatchUpdate(with indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func showLikeError(_ error: Error) {
        let alert = UIAlertController(
            title: "Не удалось лайкнуть фото",
            message: "\(error.localizedDescription)",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.delegate = self
        let photo = imagesListService.photos[indexPath.row]
        let likedImage = photo.isLiked ? UIImage(named: "like_active") : UIImage(named: "like_inactive")
        cell.likeButton.setImage(likedImage, for: .normal)
        cell.dateLabel.text = (photo.createdAt != nil) ? dateFormatter.string(from: photo.createdAt!) : ""
        guard let url = URL(string: photo.thumbImageURL) else { return }
        let placeholder = UIImage(named: "stub") ?? UIImage()
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url, placeholder: placeholder) { [weak self] _ in
            guard let self else { return }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photos[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photos[indexPath.row].size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        presenter?.didTapLike(for: cell)
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as! ImagesListCell
        cell.delegate = self
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
        ImagesListService.shared.fetchPhotosNextPage()
    }
}
