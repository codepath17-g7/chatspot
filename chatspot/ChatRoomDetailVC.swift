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
    @IBOutlet weak var footerView: UIView!
    
    var chatroom: ChatRoom1!
    
    var userList = [User1]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = chatroom.name
        
        setupUI()
        
        let users = chatroom.isAroundMe ? chatroom.localUsers : chatroom.users
        
        users?.keys.forEach({ (userGuid) in
            //
            ChatSpotClient.getUserProfile(userGuid: userGuid, success: { (user) in
                self.userList.append(user)
                self.tableView.reloadData()
            }, failure: {})
        })
    }
    
    private func setupUI() {
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        footerView.isHidden = chatroom.isAroundMe
        
        let cellNib = UINib.init(nibName: "UserCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "userCell")
        
        if let latitude = chatroom.latitude,
            let longitude = chatroom.longitude {
            
            let headerView = MapBannerView()
            headerView.loadFromXib()
            tableView.tableHeaderView = headerView
            
            headerView.setLocation(latitude, longitude)
        }
    }
    
    @IBAction func leaveRoom(_ sender: UIButton) {
        ChatSpotClient.leaveChatRoom(userGuid: Auth.auth().currentUser!.uid, roomGuid: chatroom.guid)
        // ignoring the return value. `_ =` is a swift convention it appears!
        _ = navigationController?.popToRootViewController(animated: true)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = userList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! UserCell
        cell.user = user
        return cell
    }
}

