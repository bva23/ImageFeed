//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 05.06.2023.
//

import UIKit
// import ProgressHUD

final class SplashViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let authService = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let profileImageService = ProfileImageService.shared
    private let alertPresenter = AlertPresenter()
    private var wasChecked: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func checkAuthStatus() {
        guard !wasChecked else { return }
        
        wasChecked = true
        if authService.isAuthenticated {
            UIBlockingProgressHUD.show()
            
            fetchProfile()
            UIBlockingProgressHUD.dismiss()
            self.switchToTabBarController()
        } else {
            showAuthController()
        }
    }
    private func showAuthController() {
        let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "AuthViewControllerID")
        guard let authViewController = viewController as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func presentAuth() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(identifier: "AuthViewControllerID")
        guard let authViewController = viewController as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}
extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            UIBlockingProgressHUD.show()
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        UIBlockingProgressHUD.show()
        
        authService.fetchOAuthToken(code) { [weak self] authResult in
            switch authResult {
            case .success(_):
                self?.fetchProfile()
            case .failure (let error):
                self?.showLoginAlert(error: error)
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
    
    private func fetchProfile() {
        profileService.fetchProfile { [weak self] profileResult in
            switch profileResult {
            case .success(_):
                self?.switchToTabBarController()
            case .failure(let error):
                self?.showLoginAlert(error: error)
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    private func showLoginAlert(error: Error) {
        alertPresenter.showAlert(title: "Что-то пошло не так :(",
                                 message: "Не удалось войти в систему, \(error.localizedDescription)") {
            self.performSegue(withIdentifier: self.ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
}
