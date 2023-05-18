//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 16.05.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    @IBAction private func didTapLogoutButton(_ sender: Any) {
    }
    
    @IBOutlet private var userpickImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var usernameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var logoutButton: UIButton!
}
