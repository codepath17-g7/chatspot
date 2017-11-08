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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userBannerImageView: UIImageView!
    @IBOutlet weak var userProfilePictureImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userTaglineLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    
    
    var user = Auth.auth().currentUser!
//    var userProfile: User1!
    
    fileprivate var tableViewData = [SectionWithItems]()
    private var userSection: SectionWithItems!
    private var activitySection: SectionWithItems!
    private var isSelf: Bool!

    
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
    
    
    private func setupUI() {
        tableView.backgroundColor = UIColor.ChatSpotColors.LighterGray
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        
        var roomBanner: UIImage?
        if let urlString = self.chatroom.banner,
            let url = URL(string: urlString),
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data) {
            print("Banner height - \(image.size.height)")
            roomBanner = image
        }
        
        guard let bannerImage = roomBanner else {
            print("problem")
            return
        }
        
//        let chatroomTitleLabel = UILabel(frame: CGRect(x: 16, y: 16, width: 150, height: 130))
//        chatroomTitleLabel.attributedText = NSAttributedString(string: "\(self.chatroom.name!)", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.Chatspot.extraLarge])
//        chatroomTitleLabel.numberOfLines = 3
//        chatroomTitleLabel.sizeToFit()
        
        
        let headerView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200))
        headerView.image = bannerImage
        
        // Add a gradient only if there is a banner picture
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = headerView.frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.2, 1]
        headerView.layer.insertSublayer(gradient, at: 0)
        

        
        
        self.tableView.tableHeaderView = headerView
        
        
//        self.tableView.tableHeaderView!.transform = self.tableView.transform
        
        
        self.view.layoutIfNeeded()
        
        
        let cellNib = UINib.init(nibName: "UserCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "userCell")
        
        let mapCellNib = UINib.init(nibName: "MapCell", bundle: nil)
        tableView.register(mapCellNib, forCellReuseIdentifier: "mapCell")
        
        let activityCellNib = UINib.init(nibName: "ActivityCell", bundle: nil)
        tableView.register(activityCellNib, forCellReuseIdentifier: "activityCell")
        
    }
    
    func setupUserData(user: User1, isSelf: Bool) {

//        self.user = user
        self.isSelf = isSelf
        
        if let imgUrlStr = user.profileImage {
            userProfilePictureImageView.safeSetImageWith(urlStr: imgUrlStr)
        } else {
            userProfilePictureImageView.image = #imageLiteral(resourceName: "image-placeholder")
        }
        
        
        if let bannerUrlStr = user.bannerImage {
            userBannerImageView.safeSetImageWith(urlStr: bannerUrlStr)
        } else {
            userBannerImageView.image = UIImage()
        }
        
        usernameLabel.text = user.name
//        userNameField.text = user.name
        
        if let tagline = user.tagline {
            userTaglineLabel.text = tagline
//            userTaglineField.text = tagline
        }
        
        if isSelf {
            profileImage.showEditView()
            bannerImage.showEditView()
            
            
            sendMessageButton.isHidden = true
            editUserNameButton.isHidden = false
            editUserTaglineButton.isHidden = false
        } else {
            profileImage.hideEditView()
            bannerImage.hideEditView()
            
            sendMessageButton.isHidden = false
            editUserNameButton.isHidden = true
            editUserTaglineButton.isHidden = true
        }
    }

    
    
    func fetchUserProfile() {
        ChatSpotClient.getUserProfile(userGuid: user.uid, success: { (userProfile: User1) in
            self.setupUserData(user: userProfile, isSelf: true)
//            self.userProfile = userProfile
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

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData[section].sectionItems.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewData[section].sectionTitle
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataItem = tableViewData[indexPath.section]
        if let rows = dataItem.sectionItems as? [String],
            rows.first == "Leave \(chatroom.name!)" {
            leaveRoom()
        }
        tableView.deselectRow(at: indexPath, animated:true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dataItem = tableViewData[indexPath.section]
        if (dataItem.sectionTitle == "Location") {
            return 125
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerTitle = view as? UITableViewHeaderFooterView {
            headerTitle.textLabel?.font = UIFont(name: UIFont.AppFonts.bigRegular, size: UIFont.AppSizes.larger)
            headerTitle.textLabel?.textColor = UIColor.ChatSpotColors.LightGray
            headerTitle.tintColor = UIColor.ChatSpotColors.LighterGray
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionItems = tableViewData[indexPath.section].sectionItems
        var cell: UITableViewCell!
        if let userSectionItems = sectionItems as? [User1] {
            let user = userSectionItems[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "userCell")
            (cell as! UserCell).user = user
            cell.accessoryType = .disclosureIndicator
        } else if let leaveSectionItems = sectionItems as? [String] {
            let item = leaveSectionItems[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "userCell")
            (cell as! UserCell).name.text = item
            cell.accessoryType = .none
        } else if let mapCellItems = sectionItems as? [CLLocationCoordinate2D] {
            let item = mapCellItems[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "mapCell")
            (cell as! MapCell).setLocation(coordinate: item)
        } else if let activityItems = sectionItems as? [Activity] {
            let item = activityItems[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "activityCell")
            let activityCell = cell as! ActivityCell
            activityCell.activity = item
            if item.activityName == "See All Activities" {
                activityCell.actionButton.isHidden = true
                activityCell.accessoryType = .disclosureIndicator
            } else {
                activityCell.actionButton.isHidden = false
                activityCell.accessoryType = .none
            }
            
            activityCell.action = { shouldJoin, activityGuid in
                
                let activity = activityItems.first(where: { (activity) -> Bool in activity.guid == activityGuid })
                let userGuid = ChatSpotClient.currentUser.guid!
                
                if (shouldJoin) {
                    print("Join activity \(activity!.activityName!)")
                    ChatSpotClient.joinActivity(roomGuid: self.chatroom.guid, activityGuid: activityGuid, userGuid: userGuid, success: {
                        activity?.usersJoined[userGuid] = true
                    }, failure: {})
                } else {
                    print("Leave activity \(activity!.activityName!)")
                    ChatSpotClient.leaveActivity(roomGuid: self.chatroom.guid, activityGuid: activityGuid, userGuid: userGuid, success: {
                        activity?.usersJoined.removeValue(forKey: userGuid)
                    }, failure: {})
                }
            }
        }
        return cell
    }
}
