//
//  AppDelegate.swift
//  chatspot
//
//  Created by Syed Hakeem Abbas on 10/8/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import Firebase
import FirebaseAuthUI
import GTMSessionFetcher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    override init() {
        FirebaseApp.configure()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Successfully running this sample requires an app in Firebase and an
        // accompanying valid GoogleService-Info.plist file.
        // handleUserAuthentication()
        GTMSessionFetcher.setLoggingEnabled(true)
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
       // return self.handleOpenUrl(url, sourceApplication: sourceApplication)
       return  (FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication))!
    }
    
    @available(iOS 8.0, *)
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        //return self.handleOpenUrl(url, sourceApplication: sourceApplication)
        return (FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication))!
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification notification: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(notification)
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
        }
        
    }
    
    
    func handleOpenUrl(_ url: URL, sourceApplication: String?) -> Bool {
        print("url: \(url)")
       
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    func handleUserAuthentication() {
        if Auth.auth().currentUser != nil {
            print("There is a current user")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "tabBarController") as! ChatListVC
            window?.rootViewController = vc
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "authViewController") as! ChatListVC
            window?.rootViewController = vc
            print("There is no current user")
        }
    }
}

