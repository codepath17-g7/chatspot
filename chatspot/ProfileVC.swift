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
    
    // note: hidebottombaronpush is set
    
    
    @IBOutlet weak var profileView: ProfileView!
//    var currentUser = ChatSpotClient.currentUser
//    var user: User1!
    fileprivate var tableViewData = [SectionWithItems]()
    private var badgeSection: SectionWithItems!


    var user: User1!
    var otherUserGuid: String?
//    var isSelfProfile: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileView.tableView.dataSource = self
        profileView.tableView.delegate = self
        
        if navigationController?.restorationIdentifier == "ProfileNavigationController" {
//            isSelfProfile = true
            setupSelfProfile()


        } else {
//            isSelfProfile = false
            setupOtherUserProfile()
        }
        
        
        ChatSpotClient.getBadges(userGuid: user.guid!, success: { (badges: [Badge]) in

            if (badges.count == 0) {
                return
            }
            
            self.badgeSection = SectionWithItems("Badges", Array(badges.prefix(3)))
//            let seeAll = Activity()
            let seeAll = Badge(badgeType: .oneHundredMessagesSentInChannel, chatspotName: "See All Badges")
//
            self.badgeSection.sectionItems.append(seeAll)
            self.tableViewData.insert(self.badgeSection, at: 0)
            self.profileView.tableView.reloadData()

        }, failure: {
            print("Failure retrieving badges")
        })
        
        let badgeCellNib = UINib.init(nibName: "BadgeCell", bundle: nil)
        profileView.tableView.register(badgeCellNib, forCellReuseIdentifier: "badgeCell")
        
        let userCellNib = UINib.init(nibName: "UserCell", bundle: nil)
        profileView.tableView.register(userCellNib, forCellReuseIdentifier: "userCell")
        
    }
    
    func setupSelfProfile(){
        user = ChatSpotClient.currentUser
        self.navigationItem.setUpTitle(title: "Profile")
        tableViewData.append(SectionWithItems(" ", ["Logout"]))
        
        let rightItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editProfile))
        
        rightItem.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont.Chatspot.regular], for: .normal)

        navigationItem.rightBarButtonItem = rightItem
        
        self.profileView.setupUserInfo(user: user)

        self.hidesBottomBarWhenPushed = false

        //if from profile tab click:
        //-get current user
        //-get current user info and badges
        //-show logout cell
        //-show edit profile button
        //-tab bar visible
        //-nav bar profile title set
        
    }
    
    func editProfile(){
        
    }
    
    func setupOtherUserProfile(){//depending on how this VC is presented, change the nav left bar button item to be either a chevron or an x (and make navbar clear)
        
        ChatSpotClient.getUserProfile(userGuid: otherUserGuid!, success: { (user: User1) in
            self.user = user
            self.profileView.setupUserInfo(user: user)
            ////            self.userView.prepare(user: userProfile, isSelf: true)
            //            self.profileView.setupUserInfo(user: user, isSelf: true)
            //        }) {
            //            print("Could not get user profile for \(self.user.displayName ?? "") \(self.user.uid)")
            //        }
            //    }
        }, failure: {})
        
        self.hidesBottomBarWhenPushed = true
        
        self.navigationController?.navigationBar.isHidden = true
        
        let closeButton = UIButton(frame: CGRect(x: profileView.headerView.frame.origin.x + 16, y: profileView.headerView.frame.origin.y + 16, width: 24, height: 24))
        closeButton.setImage(#imageLiteral(resourceName: "xIcon"), for: .normal)
        closeButton.changeImageViewTo(color: .white)
        closeButton.sizeToFit()
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.view.addSubview(closeButton)

        
        
        //
        //if viewing other user profile:
        //-push onto nav stack (no title view in left bar button)
        //-hide tab bar
        //-make call to fetch user info
        //-populate badge cells with badges
        //-hide logout cell
        //-hide edit profile button
    }
    
    
    func close() { //    @objc private
        self.dismiss(animated: true, completion: nil)
    }
    
    func logout() {
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
            rows.first == "Logout" {
            logout()
        }
        tableView.deselectRow(at: indexPath, animated:true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let dataItem = tableViewData[indexPath.section]
//        if (dataItem.sectionTitle == "Location") {
//            return 125
//        }
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
        if let badgeSectionItems = sectionItems as? [Badge] {
            let badge = badgeSectionItems[indexPath.row]
            if let badgeCell = tableView.dequeueReusableCell(withIdentifier: "badgeCell") as? BadgeCell {
                cell = badgeCell
            } else {
                cell = BadgeCell()
            }
            (cell as! BadgeCell).badge = badge
            if badge.chatspotName == "See All Badges" { // hacky. fix all this.
                (cell as! BadgeCell).badgeImageView = nil
            }
            cell.accessoryType = .none
        } else if let logoutSectionItems = sectionItems as? [String] {
            let item = logoutSectionItems[indexPath.row]
            if let userCell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserCell {

//            if let userCell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserCell{
                cell = userCell
            } else {
                cell = UserCell()
            }
            (cell as! UserCell).name.text = item
            cell.accessoryType = .none
        }
        return cell
    }

}


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




//    func fetchUserProfile() {
//        ChatSpotClient.getUserProfile(userGuid: user.guid, success: { (user: User1) in
//            self.user = user
////            self.userView.prepare(user: userProfile, isSelf: true)
//            self.profileView.setupUserInfo(user: user, isSelf: true)
//        }) {
//            print("Could not get user profile for \(self.user.displayName ?? "") \(self.user.uid)")
//        }
//    }

//        // Get current user info
//        fetchUserProfile()




//        let users = chatroom.isAroundMe ? chatroom.localUsers : chatroom.users
//
//        users?.keys.forEach({ (userGuid) in
//
//            ChatSpotClient.getUserProfile(userGuid: userGuid, success: { (user) in
//
//                if (self.userSection == nil) {
//                    let seeAll = User1()
//                    seeAll.name = "See All Members"
//                    self.userList.append(seeAll)
//                    self.userSection = SectionWithItems("Members", self.userList)
//                    self.tableViewData.insert(self.userSection, at: self.tableViewData.count - 1)
//                }
//                self.userList.insert(user, at: self.userList.count - 1)
//
//                if (self.userList.count <= 3) {
//                    self.userSection.sectionItems = self.userList
//                    self.tableView.reloadData()
//                }
//
//            }, failure: {})
//        })


