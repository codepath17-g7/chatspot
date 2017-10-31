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
    @IBOutlet weak var leaveButton: UIButton!
    
    var chatroom: ChatRoom1!
    
    var userList = [User1]()
    let sections = ["Members"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.setUpTitle(title: chatroom.name)
        
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(image: UIImage.init(named: "x-button"),
                            style: UIBarButtonItemStyle.plain,
                            target: self,
                            action: #selector(close))
        
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
    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupUI() {
        
        leaveButton.layer.cornerRadius = 4
        
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
        
        
        footerView.isHidden = chatroom.isAroundMe
        
        let cellNib = UINib.init(nibName: "UserCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "userCell")
        
        if let latitude = chatroom.latitude,
            let longitude = chatroom.longitude {
            
            let headerView = MapBannerView()
            headerView.loadFromXib()
            //tableView.tableHeaderView = headerView
            
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let headerView = self.tableView.tableHeaderView as! ParallaxView
        headerView.scrollViewDidScroll(scrollView: scrollView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated:true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = userList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! UserCell
        cell.user = user
        return cell
    }
}

