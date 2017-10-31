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
    
    var chatroom: ChatRoom1!
    
    private var userList = [User1]()
    private var activityList = [Activity]()
    
    fileprivate var tableViewData = [SectionWithItems]()
    private var userSection: SectionWithItems!
    private var activitySection: SectionWithItems!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.setUpTitle(title: chatroom.name)
        
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(image: UIImage.init(named: "x-button"),
                            style: UIBarButtonItemStyle.plain,
                            target: self,
                            action: #selector(close))
        
        setupUI()
        
        tableViewData.append(SectionWithItems(" ", ["Leave \(chatroom.name!)"]))
        
        let users = chatroom.isAroundMe ? chatroom.localUsers : chatroom.users
        
        users?.keys.forEach({ (userGuid) in
            //
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
    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupUI() {
        
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        DispatchQueue.global(qos: .utility).async {
            
            var roomBanner: UIImage?
            if let urlString = self.chatroom.banner,
                let url = URL(string: urlString),
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data) {
                print("Banner height - \(image.size.height)")
                roomBanner = image
            }
            
            guard let bannerImage = roomBanner else {
                return
            }
            
            DispatchQueue.main.async {
                let headerView = ParallaxView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 150), image: bannerImage)
                self.tableView.tableHeaderView = headerView
                self.tableView.tableHeaderView!.transform = self.tableView.transform
            }
        }
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let headerView = tableView.tableHeaderView {
            
            let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            
            //Comparison necessary to avoid infinite loop
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension ChatRoomDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let headerView = self.tableView.tableHeaderView as? ParallaxView {
            headerView.scrollViewDidScroll(scrollView: scrollView)
        }
    }
    
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
            headerTitle.textLabel?.textColor = UIColor.ChatSpotColors.LightGray
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionItems = tableViewData[indexPath.section].sectionItems
        var cell: UITableViewCell!
        if let userSectionItems = sectionItems as? [User1] {
            let user = userSectionItems[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "userCell")
            (cell as! UserCell).user = user
        } else if let leaveSectionItems = sectionItems as? [String] {
            let item = leaveSectionItems[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "userCell")
            (cell as! UserCell).name.text = item
        } else if let mapCellItems = sectionItems as? [CLLocationCoordinate2D] {
            let item = mapCellItems[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "mapCell")
            (cell as! MapCell).setLocation(coordinate: item)
        } else if let activityItems = sectionItems as? [Activity] {
            let item = activityItems[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "activityCell")
            let activityCell = cell as! ActivityCell
            activityCell.activity = item
            activityCell.actionButton.isHidden = (item.activityName == "See All Activities")
            
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
