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

class AuthViewController: UIViewController, FUIAuthDelegate{
    fileprivate(set) var authStateDidChangeHandle: AuthStateDidChangeListenerHandle?
    fileprivate(set) var auth: Auth? = Auth.auth()
    fileprivate(set) var authUI: FUIAuth? = FUIAuth.defaultAuthUI()
    fileprivate(set) var customAuthUIDelegate: FUIAuthDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            self.authUI?.providers = [provider]
            let controller = self.authUI!.authViewController()
            //controller.navigationBar.isHidden = self.customAuthorizationSwitch.isOn
            self.present(controller, animated: true, completion: nil)
            
        }
        
    }
    
    func updateUI(auth: Auth, user: FirebaseAuth.User?) {
        if let user = self.auth?.currentUser {
            print("Signed In")
            /*self.cellSignedIn.textLabel?.text = "Signed in"
            self.cellName.textLabel?.text = user.displayName ?? "(null)"
            self.cellEmail.textLabel?.text = user.email ?? "(null)"
            self.cellUid.textLabel?.text = user.uid
            self.cellPhone.textLabel?.text = user.phoneNumber
            
            self.authorizationButton.title = "Sign Out";*/
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
