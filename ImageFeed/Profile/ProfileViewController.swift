//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 16.05.2023.
//

import UIKit
import Kingfisher
import WebKit

protocol ProfileViewControllerProtocol: AnyObject {
    func updateAvatar(url: URL?)
    func updateProfileDetails(profile: Profile?)
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    lazy var presenter: ProfilePresenterProtocol = ProfileViewPresenter(view: self)
    
    private let alertPresenter = AlertPresenter()

    @IBAction private func didTapLogoutButton(_ sender: Any) {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)
        
        let confirmExitAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            presenter.clean()
            self.present(SplashViewController(), animated: true, completion: nil)
        }
        
        let cancelExitAction = UIAlertAction(title: "Нет", style: .default) { _ in }
        
        alert.addAction(confirmExitAction)
        alert.addAction(cancelExitAction)
        
        self.present(alert, animated: true)
    }
    
    @IBOutlet private lazy var profileImageView: UIImageView! = {
        let userpickImage = UIImage()
        let imageView = UIImageView(image: userpickImage)
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    @IBOutlet private lazy var nameLabel: UILabel! = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = .boldSystemFont(ofSize: 23)
        label.textColor = UIColor.ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    @IBOutlet private lazy var loginNameLabel: UILabel! = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = .systemFont(ofSize: 13)
        label.textColor = UIColor.ypGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    @IBOutlet private lazy var descriptionLabel: UILabel! = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = .systemFont(ofSize: 13)
        label.textColor = UIColor.ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    @IBOutlet private lazy var logoutButton: UIButton! = {
        let button = UIButton.systemButton(
            with: UIImage(named: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(Self.didTapLogoutButton)
        )
        button.titleLabel?.font = UIFont.systemFont(ofSize: 120, weight: .heavy)
        button.tintColor = UIColor.ypRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    internal func updateProfileDetails(profile: Profile?) {
        guard let profile else { return }
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    @objc
    private func updateAvatar(notification: Notification) {
        guard
            isViewLoaded,
            let userInfo = notification.userInfo,
            let profileImageURL = userInfo["URL"] as? String,
            let url = URL(string: profileImageURL)
        else { return }
        
        updateAvatar(url: url)
    }
    
    func updateAvatar(url: URL?) {
        guard let url else { return }
        let placeholderImage = UIImage(systemName: "no_avatar")
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: url, placeholder: placeholderImage)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = ProfileImageService.shared.avatarURL {
            updateAvatar(url: url)
        }
        
        view.addSubview(profileImageView)
        profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.layer.cornerRadius = 35
        profileImageView.clipsToBounds = true
        
        
        view.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        
        view.addSubview(loginNameLabel)
        loginNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
        loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        
        view.addSubview(descriptionLabel)
        descriptionLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
        
        view.addSubview(logoutButton)
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let profile = ProfileService.shared.profile else {
            assertionFailure("no saved profile")
            return }
        
        self.nameLabel.text = profile.name
        self.descriptionLabel.text = profile.bio
        self.loginNameLabel.text = profile.loginName
        
        // profileImageService.fetchProfileImageURL(userName: profile.username) { _ in }
    }
    

}
