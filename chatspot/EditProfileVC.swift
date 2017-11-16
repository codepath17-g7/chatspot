//
//  EditProfileVC.swift
//  chatspot
//
//  Created by Eden on 11/15/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class EditProfileVC: UITableViewController {
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    @IBOutlet weak var editBannerButton: UIButton!
    @IBOutlet weak var editProfilePicButton: UIButton!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var taglineTextField: UITextField!
    
    
    
    
    var user: User1!
    fileprivate var imageToPick: ImageToPick?
    
    fileprivate var profilePicEdited: Bool = false
    fileprivate var bannerEdited: Bool = false
    
    enum ImageToPick {
        case profile, banner
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editBannerButton.imageView?.setRadiusWithShadow()
        editProfilePicButton.imageView?.setRadiusWithShadow()

        let tapAwayFromKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapAwayFromKeyboard)
        
        let titleLabel = UILabel()
        let attributedString = NSAttributedString(string: "Profile", attributes: [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont.Chatspot.regularNavigationTitle])
        titleLabel.attributedText = attributedString
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        
//        let leftItem = UIBarButtonItem(customView: titleLabel)
//        self.leftBarButtonItem = leftItem
        
    }
    
    
//    let rightItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editProfile))
//    
//    rightItem.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont.Chatspot.regular], for: .normal)
//    
//    navigationItem.rightBarButtonItem = rightItem

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            usernameTextField.becomeFirstResponder()
        } else if indexPath.row == 1 {
            taglineTextField.becomeFirstResponder()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func editBannerButtonClicked(_ sender: Any) {
        self.imageToPick = .banner
        self.pickImage()
        
    }
   
    @IBAction func editProfilePicButtonClicked(_ sender: Any) {
        self.imageToPick = .profile
        self.pickImage()
    }
    
    func persistUserEdit() {
        ChatSpotClient.updateUserProfile(user: user)
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "cancel", sender: self)
    }


    @IBAction func saveButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "save", sender: self)
    }
    
    
    
    func hideKeyboard(){
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "save" {
            
            user.name = usernameTextField.text
            user.tagline = taglineTextField.text
            persistUserEdit()
            let profileVC = segue.destination as! ProfileVC
            
            if profilePicEdited {
                profileVC.profileView.profilePictureImageView.image = profilePicImageView.image
                StorageClient.instance.storeProfileImage(userGuid: ChatSpotClient.userGuid, profileImage: profilePicImageView.image!, success: { (url :URL?) in
                    self.user.profileImage = url?.absoluteURL.absoluteString
                    self.persistUserEdit()
                    profileVC.setupUserInformation(user: self.user)
                }, failure: {
                    
                })
            }
            if bannerEdited {
                profileVC.profileView.bannerImageView.image = bannerImageView.image
                StorageClient.instance.storeBannerImage(userGuid: ChatSpotClient.userGuid, bannerImage: bannerImageView.image!, success: { (url :URL?) in
                    self.user.bannerImage = url?.absoluteURL.absoluteString
                    self.persistUserEdit()
                    profileVC.setupUserInformation(user: self.user)
                }, failure: {
                    
                })
            }
        }
    }
    


    
    private func pickImage() {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = false
        vc.sourceType = .photoLibrary
        
        self.present(vc, animated: true, completion: nil)
//        let appdelegate = UIApplication.shared.delegate as! AppDelegate
//        let topVc = topViewController(from: appdelegate.window?.rootViewController)
//        topVc?.present(vc, animated: true, completion: nil)
    }
}


extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        picker.dismiss(animated: true, completion: nil)
        
        switch imageToPick! {
        case .profile:
            profilePicImageView.image = originalImage
            profilePicEdited = true
            break
        case .banner:
            bannerImageView.image = originalImage
            bannerEdited = true
            break
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}



// MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 2
//    }

/*
 override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
 
 // Configure the cell...
 
 return cell
 }
 */
// Uncomment the following line to preserve selection between presentations
// self.clearsSelectionOnViewWillAppear = false

// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
// self.navigationItem.rightBarButtonItem = self.editButtonItem()

//    @IBAction func onEditUserName(_ sender: Any) {
//        if !editingUserName {
//            contentView.bringSubview(toFront: userNameField)
//            userNameField.becomeFirstResponder()
//        } else {
//            userName.text = userNameField.text
//            contentView.bringSubview(toFront: userName)
//            user.name = userNameField.text
//            persistUserEdit()
//        }
//        editingUserName = !editingUserName
//    }

//    @IBAction func onEditUserTagline(_ sender: Any) {
//        if !editingUserTagline {
//            contentView.bringSubview(toFront: userTaglineField)
//            userTaglineField.becomeFirstResponder()
//        } else {
//            userTagline.text = userTaglineField.text
//            contentView.bringSubview(toFront: userTagline)
//            user.tagline = userTaglineField.text
//            persistUserEdit()
//        }
//        editingUserTagline = !editingUserTagline
//    }

// Get the new view controller using [segue destinationViewController].
// Pass the selected object to the new view controller.

////     Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
////         Return false if you do not want the specified item to be editable.
//        return true
//    }



