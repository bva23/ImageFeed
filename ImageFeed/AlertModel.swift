//
//  AlertModel.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 14.08.2023.
//

import Foundation

struct AlertModel {
    var title: String
    var message: String
    var primaryButtonText: String
    var primaryButtonCompletion: (() -> ())
    var secondaryButtonText: String?
    var secondaryButtonCompletion: (() -> ())?
}
