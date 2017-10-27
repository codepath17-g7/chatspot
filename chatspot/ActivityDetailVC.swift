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
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIButton!
    
    var activity: Activity!
    var section0 = [User1]()
    var participatingUsers = [User1]()
    var numOfSections = 1;
    var roomGuid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.target = self
        closeButton.action = #selector(close)
        // Do any additional setup after loading the view.
        
        let cellNib = UINib.init(nibName: "UserCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "userCell")
        
        let aUser = User1(guid: "none", obj: ["name": "\(activity.activityStartedByName!) started \(activity.activityName!)"])
        section0.append(aUser)
        
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        showActionButton()
        
        activity.usersJoined.forEach({ (entry) in
            ChatSpotClient.getUserProfile(userGuid: entry.key, success: { (user) in
                self.numOfSections = 2
                self.participatingUsers.append(user)
                self.tableView.reloadData()
            }, failure: {})
        })
        
    }
    
    @IBAction func onTapActionButton(_ sender: Any) {
        
        let userGuid = ChatSpotClient.currentUser.guid!
        
        if (isCurrentUserJoined()) {
            
            print("Leaving activity")
            
            ChatSpotClient.leaveActivity(roomGuid: roomGuid!, activityGuid: activity.guid!, userGuid: userGuid, success: {
                
                self.activity.usersJoined.removeValue(forKey: userGuid)
                
                let index = self.participatingUsers.index { return $0.guid == userGuid} ?? -1
                
                if (index != -1) {
                    self.participatingUsers.remove(at: index)
                    self.tableView.reloadData()
                    self.showActionButton()
                }
                
            }, failure: {})
        } else {
            
            print("Joining activity")
            
            ChatSpotClient.joinActivity(roomGuid: roomGuid!, activityGuid: activity.guid!, userGuid: userGuid, success: {
                
                self.activity.usersJoined[userGuid] = true
                
                self.participatingUsers.append(ChatSpotClient.currentUser)
                
                self.tableView.reloadData()
                
                self.showActionButton()
                //
            }, failure: {})
        }
        
    }
    
    private func showActionButton() {
        
        actionButton.layer.cornerRadius = 4
        
        if (isCurrentUserJoined()) {
            
            actionButton.setTitle("LEAVE ACTIVITY", for: .normal)
            actionButton.backgroundColor = UIColor.red
        } else {
            
            actionButton.setTitle("JOIN ACTIVITY", for: .normal)
            actionButton.backgroundColor = UIColor.ChatSpotColors.LightBlue
        }
    }
    
    private func isCurrentUserJoined() -> Bool {
        
        return activity.usersJoined.contains { (key, value) -> Bool in
            return key == ChatSpotClient.currentUser.guid
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(activity)
        self.title = activity.activityName!
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
        if section == 0 {
            return section0.count
        } else {
            return participatingUsers.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Other people in the activity"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated:true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var user: User1?
        if indexPath.section == 0 {
            user = section0[indexPath.row]
        } else {
            user = participatingUsers[indexPath.row]
            if (user?.guid == ChatSpotClient.currentUser.guid) {
                user?.name = "You"
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! UserCell
        cell.user = user
        return cell
    }
    
}
