//
//  ProfileTest.swift
//  ImageFeedTest
//
//  Created by Владимир Богомолов on 21.08.2023.
//

@testable import ImageFeed
import XCTest

final class ProfileViewPresenterSpy: ProfilePresenterProtocol {
    var view: ImageFeed.ProfileViewControllerProtocol?
    var profile: ImageFeed.Profile?
    var avatarURL: URL?
    var viewDidLoadCall: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCall = true
    }
    
    func clean() {
    }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfilePresenterProtocol?
    var updateAvatarCall = false
    var updateProfileDetailsCall = false
    
    func updateAvatar(url: URL?) {
        updateAvatarCall = true
    }
    
    func updateProfileDetails(profile: ImageFeed.Profile?) {
        updateProfileDetailsCall = true
    }
    
    func didTapLogoutButton() {
    }
}

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCall)
    }
    
    func testPresenterCallsUpdateProfileDetails() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter(view: viewController)
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewController.updateProfileDetailsCall)
    }
    
    func testPresenterCallsUpdateAvatar() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter(view: viewController)
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewController.updateAvatarCall)
    }
}

