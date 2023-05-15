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
    
    static let reuseIdentifier = "ImagesListCell"
}
