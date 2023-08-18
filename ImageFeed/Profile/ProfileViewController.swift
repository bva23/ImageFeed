//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 16.05.2023.
//

import UIKit
import Kingfisher
import WebKit

final class ProfileViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let authService = OAuth2Service()
    private let alertPresenter = AlertPresenter()
    private var profileImageServiceObserver: NSObjectProtocol?
    static let LogoutNotification = Notification.Name(rawValue: "Logoutcompleted")
    
    @IBAction private func didTapLogoutButton(_ sender: Any) {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)
        
        let confirmExitAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.clean()
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
    
    private func updateProfileDetails(profile: Profile) {
        guard let profile = profileService.profile else { return }
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
    
    private func updateAvatar(url: URL) {
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: url)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = ProfileImageService.shared.avatarURL {
            updateAvatar(url: url)
        }
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.updateAvatar(notification: notification)
        }
        
        updateProfileDetails(profile: profileService.profile!)
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let profile = ProfileService.shared.profile else {
            assertionFailure("no saved profile")
            return }
        
        self.nameLabel.text = profile.name
        self.descriptionLabel.text = profile.bio
        self.loginNameLabel.text = profile.loginName
        
        profileImageService.fetchProfileImageURL(userName: profile.username) { _ in }
    }
    
    private func clean() {
        let tokenStorage = OAuth2TokenStorage.shared
        tokenStorage.removeToken()
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
