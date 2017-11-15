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
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            usernameTextField.becomeFirstResponder()
        }
        tableView.deselectRow(at: indexPath, animated: true)
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


//     Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//         Return false if you do not want the specified item to be editable.
        return true
    }


   

}
