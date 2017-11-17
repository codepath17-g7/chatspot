//
//  AuthViewController.swift
//  chatspot
//
//  Created by Syed Hakeem Abbas on 10/14/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit
import FirebaseAuthUI
import FirebasePhoneAuthUI
import FirebaseGoogleAuthUI


enum Providers: Int, RawRepresentable {
    case Google
    case Phone
}

class AuthViewController: UIViewController, FUIAuthDelegate{
    fileprivate(set) var authStateDidChangeHandle: AuthStateDidChangeListenerHandle?
    fileprivate(set) var auth: Auth? = Auth.auth()
    fileprivate(set) var authUI: FUIAuth? = FUIAuth.defaultAuthUI()
    fileprivate(set) var customAuthUIDelegate: FUIAuthDelegate!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 4
        loginButton.backgroundColor = UIColor.ChatSpotColors.SelectedBlue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.customAuthUIDelegate = self
        self.authStateDidChangeHandle =
            self.auth?.addStateDidChangeListener({ (auth: Auth, user: FirebaseAuth.User?) in
                self.updateUI(auth: auth, user: user)
            })
        self.navigationController?.isToolbarHidden = false;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let handle = self.authStateDidChangeHandle {
            self.auth?.removeStateDidChangeListener(handle)
        }
        
        self.navigationController?.isToolbarHidden = true;
    }

    
    func authUI(_ authUI: FUIAuth, didSignInWith user: FirebaseAuth.User?, error: Error?) {
        guard let authError = error else { return }
        
        let errorCode = UInt((authError as NSError).code)
        
        switch errorCode {
        case FUIAuthErrorCode.userCancelledSignIn.rawValue:
            print("User cancelled sign-in");
            break
        default:
            let detailedError = (authError as NSError).userInfo[NSUnderlyingErrorKey] ?? authError
            print("Login error: \((detailedError as! NSError).localizedDescription)");
        }
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        if (self.auth?.currentUser) != nil {
            do {
                try self.authUI?.signOut()
            } catch let error {
                // Again, fatalError is not a graceful way to handle errors.
                // This error is most likely a network error, so retrying here
                // makes sense.
                fatalError("Could not sign out: \(error)")
            }
            
        } else {
            self.authUI?.delegate = self
            
            // If you haven't set up your authentications correctly these buttons
            // will still appear in the UI, but they'll crash the app when tapped.
            let provider = FUIPhoneAuth(authUI: self.authUI!)
            let googleProvider = FUIGoogleAuth(scopes: [kGoogleGamesScope,
                                   kGooglePlusMeScope,
                                   kGoogleUserInfoEmailScope,
                                   kGoogleUserInfoProfileScope])
            self.authUI?.providers = [provider, googleProvider]
            self.authUI?.isSignInWithEmailHidden = true
            let controller = self.authUI!.authViewController()
            self.present(controller, animated: true, completion: nil)
            
        }
        
    }
    
    func updateUI(auth: Auth, user: FirebaseAuth.User?) {
        if let user = self.auth?.currentUser {
            print("Signed In")
            ChatSpotClient.registerIfNeeded(guid: user.uid, user: user, success: {
                // don't segue till we have user object and chat list
                ChatSpotClient.getRooms(success: { (_: [ChatRoom1]) in
                    self.performSegue(withIdentifier: "loggedInSegue", sender: nil)

                }, failure: { (_: Error?) in
                })
            }, failure: {
                
            })
            // We have a logged in user, listen for location changes.
            LocationManager.instance.listenForRealtimeLocationChanges()
        } else {
            print("couldn't login")
            /*self.cellSignedIn.textLabel?.text = "Not signed in"
            self.cellName.textLabel?.text = "null"
            self.cellEmail.textLabel?.text = "null"
            self.cellUid.textLabel?.text = "null"
            self.cellPhone.textLabel?.text = "null"
            
            self.authorizationButton.title = "Sign In";*/
        }
        
        //self.cellAccessToken.textLabel?.text = getAllAccessTokens()
        //self.cellIdToken.textLabel?.text = getAllIdTokens()
    }

}
