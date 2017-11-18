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
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    private var closeButton: UIButton!
    
    var chatroom: ChatRoom1!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "userCell")
        tableView.register(UINib(nibName: "MapCell", bundle: nil), forCellReuseIdentifier: "mapCell")
        tableView.register(UINib(nibName: "ActivityCell", bundle: nil), forCellReuseIdentifier: "activityCell")
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableViewAutomaticDimension
        
        setupUsers()
        
        setupActivities()
        
        setupUI()
        
        
        if (self.parent as? BottomDrawerVC) == nil  {
            print("Parent is a chatroom")
            let panDownToDismissGesture = UIPanGestureRecognizer(target: self, action: #selector(panDownToDismiss))
            panDownToDismissGesture.delegate = self
            view.addGestureRecognizer(panDownToDismissGesture)
        }
    }
    
    
    func setupUsers(){
        let users = chatroom.isAroundMe ? chatroom.localUsers : chatroom.users
        users?.keys.forEach({ (userGuid) in
            
            ChatSpotClient.getUserProfile(userGuid: userGuid, success: { (user) in
                
                if (self.userSection == nil) {
                    let seeAll = User1()
                    seeAll.name = "See All Members"
                    self.userList.append(seeAll)
                    self.userSection = SectionWithItems("Members", self.userList)
                    if self.tableViewData.count > 0 {
                        self.tableViewData.insert(self.userSection, at: self.tableViewData.count - 1)
                    } else {
                        self.tableViewData.insert(self.userSection, at: self.tableViewData.count)
                    }
                    
                }
                self.userList.insert(user, at: self.userList.count - 1)
                
                if (self.userList.count <= 3) {
                    self.userSection.sectionItems = self.userList
                    self.tableView.reloadData()
                }
                
            }, failure: {})
        })
    }
    
    func setupActivities(){
        ChatSpotClient.getActivities(roomGuid: chatroom.guid, success: { (activities) in
            
            if (activities.count == 0) {
                return
            }
            
            self.activitySection = SectionWithItems("Activities", Array(activities.prefix(2)))
            let seeAll = Activity()
            seeAll.activityName = "See All Activities"
            self.activitySection.sectionItems.append(seeAll)
            let position = self.chatroom.isAroundMe ? 0 : 1
            self.tableViewData.insert(self.activitySection, at: position)
            self.tableView.reloadData()
        }) {}
        
        if chatroom.users?.index(forKey: ChatSpotClient.userGuid) != nil {
            tableViewData.append(SectionWithItems(" ", ["Leave \(chatroom.name!)"]))
        } else {//if user doesn't belong to chatspot
            // TODO: add join button
        }
    }
    
    
    
    func panDownToDismiss(sender: UIPanGestureRecognizer){
        let touchPoint = sender.location(in: self.view?.window)
        
        if sender.state == UIGestureRecognizerState.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizerState.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            if touchPoint.y - initialTouchPoint.y > 100 {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }
    }
    
    
    func close() {
        if let parentVC = self.parent as? BottomDrawerVC {
            parentVC.closeDrawer(completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func setupUI() { //gray color: 247, 247, 247
        tableView.backgroundColor = UIColor.ChatSpotColors.LighterGray
        tableView.separatorColor = UIColor.lightGray
        tableView.tableFooterView = UIView()
        
        let headerView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200))
        headerView.image = #imageLiteral(resourceName: "image-placeholder")
        headerView.contentMode = .scaleAspectFill
        headerView.clipsToBounds = true
        DispatchQueue.global(qos: .userInitiated).async {
            if let urlString = self.chatroom.fullSizeBanner, let url = URL(string: urlString), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                print("Banner height - \(image.size.height)")
                DispatchQueue.main.async {
                    headerView.image = image

                }
            }
        }
        
        let chatroomTitleLabel = UILabel(frame: CGRect(x: 16, y: 16, width: 150, height: 130))
        chatroomTitleLabel.attributedText = NSAttributedString(string: "\(self.chatroom.name!)", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.Chatspot.extraLarge])
        chatroomTitleLabel.numberOfLines = 3
        chatroomTitleLabel.sizeToFit()
        
            
        
        
        // Add a gradient
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = headerView.frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.2, 1]
        headerView.layer.insertSublayer(gradient, at: 0)
        chatroomTitleLabel.frame.origin.y = headerView.frame.maxY - (16 + chatroomTitleLabel.frame.height)
        
        closeButton = UIButton(frame: CGRect(x: headerView.frame.origin.x + 24, y: headerView.frame.origin.y + 28, width: 24, height: 24))
        closeButton.setImage(#imageLiteral(resourceName: "xIcon"), for: .normal)
        closeButton.changeImageViewTo(color: .white)
        closeButton.sizeToFit()
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        headerView.addSubview(chatroomTitleLabel)
        headerView.insertSubview(closeButton, at: 0)

        self.tableView.tableHeaderView = headerView
        headerView.isUserInteractionEnabled = true
        self.tableView.tableHeaderView?.isUserInteractionEnabled = true
        
        
        self.tableView.tableHeaderView!.transform = self.tableView.transform


        self.view.layoutIfNeeded()
        
        if !chatroom.isAroundMe,
            let latitude = chatroom.latitude,
            let longitude = chatroom.longitude {
            
            tableViewData.insert(SectionWithItems("Location", [CLLocationCoordinate2D(latitude: latitude, longitude: longitude)]), at: 0)
        }
    }
    
    func leaveRoom() {
        print("leaveroom called")
        ChatSpotClient.leaveChatRoom(userGuid: Auth.auth().currentUser!.uid, roomGuid: chatroom.guid)
        tableViewData.removeLast()
        tableView.deleteSections(IndexSet(integer: tableViewData.count), with: .automatic)
        
        if let parentVC = self.parent as? BottomDrawerVC {
            parentVC.updateJoinButton()
        } else {
           performSegue(withIdentifier: "unwindToChatList", sender: self)
        }
    }
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
    
    // TODO: allow cells to be clicked and show the extended lists
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataItem = tableViewData[indexPath.section]
        if let rows = dataItem.sectionItems as? [String],
             rows.first == "Leave \(chatroom.name!)" {
            leaveRoom()
        } else if let rows = dataItem.sectionItems as? [User1] {
//            let cell = tableView.cellForRow(at: indexPath) as! UserCell
            let user = rows[indexPath.row]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            performSegue(withIdentifier: "ChatroomDetailToProfileSegue", sender: cell)
            let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherUserGuid = user.guid
            profileVC.user = user
            profileVC.pushed = true
            self.navigationController?.pushViewController(profileVC, animated: true)
//                print("there is a nav")
//                self.navigationController?.pushViewController(profileVC, animated: true)
//            } else {
//                print("there isn't a nav")
//                if let parentVC = self.parent as? BottomDrawerVC {
//                    parentVC.navigationController?.pushViewController(profileVC, animated: true)
//                } else if let parentVC = self.parent as? ChatRoomVC {
//                    parentVC.navigationController?.pushViewController(profileVC, animated: true)
//
//                }
//            }
            
        } else if let rows = dataItem.sectionItems as? [Activity] {
            
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
            cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
            (cell as! UserCell).user = user
            cell.accessoryType = .disclosureIndicator
        } else if let leaveSectionItems = sectionItems as? [String] {
            let item = leaveSectionItems[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
            (cell as! UserCell).name.text = item
            cell.accessoryType = .none
        } else if let mapCellItems = sectionItems as? [CLLocationCoordinate2D] {
            let item = mapCellItems[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath) as! MapCell
            (cell as! MapCell).setLocation(coordinate: item)
        } else if let activityItems = sectionItems as? [Activity] {
            let item = activityItems[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! ActivityCell
            
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
                    print("Join activity \(activity!.activityName!)") // fix: activity doesn't have a name
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


