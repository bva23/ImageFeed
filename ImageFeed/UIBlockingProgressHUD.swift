//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 07.07.2023.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        setup()
        ProgressHUD.show()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
    
    static func setup() {
        ProgressHUD.colorBackground.cgColor
    }
}
