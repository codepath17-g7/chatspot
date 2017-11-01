//
//  UIViewController.swift
//  chatspot
//
//  Created by Phuong Nguyen on 10/29/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    class func topViewController(from viewController: UIViewController?) -> UIViewController? {
        if let tabBarViewController = viewController as? UITabBarController {
            return topViewController(from: tabBarViewController.selectedViewController)
        } else if let navigationController = viewController as? UINavigationController {
            return topViewController(from: navigationController.visibleViewController)
        } else if let presentedViewController = viewController?.presentedViewController {
            return topViewController(from: presentedViewController)
        } else {
            return viewController
        }
    }
    
}

extension UIViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
