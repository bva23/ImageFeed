//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 10.05.2023.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    static let reuseIdentifier = "ImagesListCell"
    
    private enum LikePhoto: String {
        case likeActive = "like_active"
        case likeInactive = "like_inactive"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    func setIsLiked(isLiked: Bool) {
        let likePhoto = isLiked ? UIImage(named: "like_active") : UIImage(named: "like_inactive")
        likeButton.setImage(likePhoto, for: .normal)
    }
}
