//
//  ChatRoomDetailVC.swift
//  chatspot
//
//  Created by Varun Kochar on 10/22/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit
import FirebaseAuth
import MapKit

class ChatRoomDetailVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var userList = [User1]()
    private var activityList = [Activity]()
    
    fileprivate var tableViewData = [SectionWithItems]()
    private var userSection: SectionWithItems!
    private var activitySection: SectionWithItems!
    
    private var closeButton: UIButton!
    
    
    var chatroom: ChatRoom1! {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        
        tableViewData.append(SectionWithItems(" ", ["Leave \(chatroom.name!)"]))
        
        let users = chatroom.isAroundMe ? chatroom.localUsers : chatroom.users
        
        users?.keys.forEach({ (userGuid) in
            
            ChatSpotClient.getUserProfile(userGuid: userGuid, success: { (user) in
                
                if (self.userSection == nil) {
                    let seeAll = User1()
                    seeAll.name = "See All Members"
                    self.userList.append(seeAll)
                    self.userSection = SectionWithItems("Members", self.userList)
                    self.tableViewData.insert(self.userSection, at: self.tableViewData.count - 1)
                }
                self.userList.insert(user, at: self.userList.count - 1)
                
                if (self.userList.count <= 3) {
                    self.userSection.sectionItems = self.userList
                    self.tableView.reloadData()
                }
                
            }, failure: {})
        })
        
        ChatSpotClient.getActivities(roomGuid: chatroom.guid, success: { (activities) in
            
            if (activities.count == 0) {
                return
            }
            
            self.activitySection = SectionWithItems("Activities", Array(activities.prefix(3)))
            let seeAll = Activity()
            seeAll.activityName = "See All Activities"
            self.activitySection.sectionItems.append(seeAll)
            let position = self.chatroom.isAroundMe ? 0 : 1
            self.tableViewData.insert(self.activitySection, at: position)
            self.tableView.reloadData()
        }) {}
        
    }
    
    func close() { //    @objc private
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupUI() { //247, 247, 247
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
        
        let chatroomTitleLabel = UILabel(frame: CGRect(x: 16, y: 16, width: 150, height: 130))
        chatroomTitleLabel.attributedText = NSAttributedString(string: "\(self.chatroom.name!)", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.Chatspot.extraLarge])
        chatroomTitleLabel.numberOfLines = 3
        chatroomTitleLabel.sizeToFit()
        
            
        let headerView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200))
        headerView.image = bannerImage
        
        // Add a gradient
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = headerView.frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.2, 1]
        headerView.layer.insertSublayer(gradient, at: 0)
        chatroomTitleLabel.frame.origin.y = headerView.frame.maxY - (16 + chatroomTitleLabel.frame.height)
        
        closeButton = UIButton(frame: CGRect(x: headerView.frame.origin.x + 16, y: headerView.frame.origin.y + 16, width: 24, height: 24))
        closeButton.setImage(#imageLiteral(resourceName: "xIcon"), for: .normal)
        closeButton.changeImageViewTo(color: .white)
        closeButton.sizeToFit()
        closeButton.addTarget(self, action: #selector(ChatRoomDetailVC.close), for: .touchUpInside)
        
        headerView.addSubview(chatroomTitleLabel)
        self.view.addSubview(closeButton)

        self.tableView.tableHeaderView = headerView
        
        
        self.tableView.tableHeaderView!.transform = self.tableView.transform


        self.view.layoutIfNeeded()
        
        
        let cellNib = UINib.init(nibName: "UserCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "userCell")
        
        let mapCellNib = UINib.init(nibName: "MapCell", bundle: nil)
        tableView.register(mapCellNib, forCellReuseIdentifier: "mapCell")
        
        let activityCellNib = UINib.init(nibName: "ActivityCell", bundle: nil)
        tableView.register(activityCellNib, forCellReuseIdentifier: "activityCell")
        
        if !chatroom.isAroundMe,
            let latitude = chatroom.latitude,
            let longitude = chatroom.longitude {
            
            tableViewData.insert(SectionWithItems("Location", [CLLocationCoordinate2D(latitude: latitude, longitude: longitude)]), at: 0)
        }
    }
    
    func leaveRoom() {
        ChatSpotClient.leaveChatRoom(userGuid: Auth.auth().currentUser!.uid, roomGuid: chatroom.guid)
        performSegue(withIdentifier: "unwindToChatList", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
////        if let headerView = tableView.tableHeaderView {
//        
////            let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
////            var headerFrame = headerView.frame
//            
//            //Comparison necessary to avoid infinite loop
//            if height != headerFrame.size.height {
//                headerFrame.size.height = height
//                headerView.frame = headerFrame
//                tableView.tableHeaderView = headerView
//            }
//        }
//    }
    
}

extension ChatRoomDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    
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

class SectionWithItems {
    
    var sectionTitle: String!
    var sectionItems: [Any]!
    
    init(_ sectionTitle: String, _ sectionItems: [Any]) {
        self.sectionTitle = sectionTitle
        self.sectionItems = sectionItems
    }
}
