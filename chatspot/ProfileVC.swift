//
//  ProfileVC.swift
//  chatspot
//
//  Created by Eden on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit
import FirebaseAuthUI



class ProfileVC: UIViewController {

//    @IBOutlet weak var userView: UserView!
    var user = Auth.auth().currentUser!
    
    var userProfile: User1!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setUpTitle(title: "Profile")
        
        fetchUserProfile()
        
//        let userWithImage = User()
        
//        userWithImage.profileImage = user.photoURL?.absoluteString
//        userWithImage.bannerImage = "https://i.ytimg.com/vi/uWmUdFIUtYs/maxresdefault.jpg"
//        
//        userWithImage.name = user.displayName //"John Snow"
//        userWithImage.tagline = "Winter is coming"
//    
//        let userNoImage = User()
//        userNoImage.name = "John Snow"
//        userNoImage.tagline = "Winter is coming"
        
//        userView.prepare(user: userNoImage, isSelf: true)
        
//        userView.prepare(user: userWithImage, isSelf: true)
//        userView.prepare(user: userWithImage, isSelf: true)
        

    }
    
    func fetchUserProfile() {
        ChatSpotClient.getUserProfile(userGuid: user.uid, success: { (userProfile: User1) in
            self.userProfile = userProfile
//            self.userView.prepare(user: userProfile, isSelf: true)
        }) { 
            print("Could not get user profile for \(self.user.displayName ?? "") \(self.user.uid)")
        }
    }
    
    @IBAction func onLogout(_ sender: UIBarButtonItem) {
        do {
            try FUIAuth.defaultAuthUI()?.signOut()
            self.performSegue(withIdentifier: "loggedOutSegue", sender: self)
            
        } catch let error {
            fatalError("Could not sign out: \(error)")
        }
    }

}
