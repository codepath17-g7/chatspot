//
//  ActivityDetailVC.swift
//  chatspot
//
//  Created by Varun on 10/26/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit
import PureLayout

class ActivityDetailVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var desctiptionLabel: UILabel!
    
    var activity: Activity!
    var participatingUsers = [User1]()
    var roomGuid: String?
    
    fileprivate var tableViewData = [SectionWithItems]()
    private var userSection: SectionWithItems!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.setUpTitle(title: activity.activityName!)
        desctiptionLabel.text = activity.activityDescription
        view.backgroundColor = UIColor.ChatSpotColors.LighterGray
        
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(image: UIImage.init(named: "x-button"),
                            style: UIBarButtonItemStyle.plain,
                            target: self,
                            action: #selector(close))
        
        // Do any additional setup after loading the view.
        
        let cellNib = UINib.init(nibName: "UserCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "userCell")
        
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        showActionButton()
        
        activity.usersJoined.forEach({ (entry) in
            ChatSpotClient.getUserProfile(userGuid: entry.key, success: { (user) in
                
                if (self.userSection == nil) {
                    self.userSection = SectionWithItems("Participants", self.participatingUsers)
                    self.tableViewData.insert(self.userSection, at: 0)
                }
                
                self.participatingUsers.append(user)
                self.userSection.sectionItems = self.participatingUsers
                self.tableView.reloadData()
                
            }, failure: {})
        })
        
    }
    
    @IBAction func onTapActionButton(_ sender: Any) {
        
        let userGuid = ChatSpotClient.currentUser.guid!
        
        print("Joining activity")
        
        ChatSpotClient.joinActivity(roomGuid: roomGuid!, activityGuid: activity.guid!, userGuid: userGuid, success: {

            self.activity.usersJoined[userGuid] = true
            self.participatingUsers.append(ChatSpotClient.currentUser)
            self.userSection.sectionItems = self.participatingUsers
            self.tableView.reloadData()
            self.showActionButton()
            
        }, failure: {})
    }
    
    private func showActionButton() {
        
        actionButton.layer.cornerRadius = 4
        
        if (!isCurrentUserJoined()) {
            
            actionButton.setTitle("Join", for: .normal)
            actionButton.backgroundColor = UIColor.ChatSpotColors.PastelRed
        } else {
            actionButton.isHidden = true
            tableView.tableHeaderView = nil
            tableViewData.append(SectionWithItems(" ", ["Leave \(activity.activityName!)"]))
            tableView.reloadData()
        }
    }
    
    private func isCurrentUserJoined() -> Bool {
        
        return activity.usersJoined.contains { (key, value) -> Bool in
            return key == ChatSpotClient.currentUser.guid
        }
    }
    
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension ActivityDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData[section].sectionItems.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewData[section].sectionTitle
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerTitle = view as? UITableViewHeaderFooterView {
            headerTitle.textLabel?.textColor = UIColor.ChatSpotColors.LightGray
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataItem = tableViewData[indexPath.section]
        if let rows = dataItem.sectionItems as? [String],
            rows.first == "Leave \(activity.activityName!)" {
            
            let userGuid = ChatSpotClient.currentUser.guid!
            ChatSpotClient.leaveActivity(roomGuid: self.roomGuid!, activityGuid: activity.guid!, userGuid: userGuid, success: {
                self.activity?.usersJoined.removeValue(forKey: userGuid)
                self.close()
            }, failure: {})
        }
        tableView.deselectRow(at: indexPath, animated:true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let sectionItems = tableViewData[indexPath.section].sectionItems
        var cell: UITableViewCell!
        if let users = sectionItems as? [User1] {
            let user = users[indexPath.row]
            if (user.guid == ChatSpotClient.currentUser.guid) {
                user.name = "You"
            }
            
            cell = tableView.dequeueReusableCell(withIdentifier: "userCell")
            (cell as! UserCell).user = user
            
        } else if let items = sectionItems as? [String] {
            let item = items[indexPath.row]
            
            cell = tableView.dequeueReusableCell(withIdentifier: "userCell")
            
            (cell as! UserCell).user = User1(guid: "dummy", obj: ["name": item])
            
            
//            activityCell.action = { shouldJoin, activityGuid in
//                
//                let activity = activityItems.first(where: { (activity) -> Bool in activity.guid == activityGuid })
//                let userGuid = ChatSpotClient.currentUser.guid!
//                
//                if (shouldJoin) {
//                    print("Join activity \(activity!.activityName!)")
//                    ChatSpotClient.joinActivity(roomGuid: self.chatroom.guid, activityGuid: activityGuid, userGuid: userGuid, success: {
//                        activity?.usersJoined[userGuid] = true
//                    }, failure: {})
//                } else {
//
//                }
//            }
        }
        
        return cell
    }
    
}
