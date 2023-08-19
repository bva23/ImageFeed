//
//  ImagesListCellDelegate.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 14.08.2023.
//

import Foundation

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
