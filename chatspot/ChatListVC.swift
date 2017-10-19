//
//  ChatListVC.swift
//  chatspot
//
//  Created by Eden on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit
import KRProgressHUD

class ChatListVC: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
    var observers = [UInt]()
	var chats: [ChatRoom1] = [ChatRoom1]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.estimatedRowHeight = 108
		tableView.rowHeight = UITableViewAutomaticDimension
        
        // Heads Up Display
        setupAndTriggerHUD()
        
        // Uncomment to add rooms for testing statically
        // ChatSpotClient.createChatRoom(name: "Oracle Arena", description: "Warriors!", banner: nil, longitude: -122.203056, latitude: 37.750278)
        // ChatSpotClient.createChatRoom(name: "Golden Gate Bridge", description: "San Francisco, California", banner: nil, longitude: -122.478611, latitude: 37.819722)
        // ChatSpotClient.createChatRoom(name: "SAP Center", description: "Sharks", banner: nil, longitude: -121.901111, latitude: 37.332778)
        
        // add in our static room
        let aroundMeRoom = ChatRoom1()
        aroundMeRoom.name = "Around Me"
        aroundMeRoom.guid = ChatSpotClient.currentUser.aroundMe
        aroundMeRoom.isAroundMe = true
        
        chats.append(aroundMeRoom)
        
        self.tableView.reloadData()
        KRProgressHUD.showSuccess()
        
        startObservingChatRoomList()
        
        startObservingLastMessage()
    }
    
    func startObservingChatRoomList() {
        let observer = ChatSpotClient.observeMyChatRooms(success: { (room: ChatRoom1) in
            self.chats.append(room)
            self.tableView.reloadData()
            KRProgressHUD.showSuccess()
        }, failure: { (error: Error?) in
            print("Error in startObservingChatRoomList: \(error)")
            KRProgressHUD.showError(withMessage: "Unable to load ChatSpots")
        })
        
        observers.append(observer)
    }
    
    func startObservingLastMessage() {
        let lastMessageObserver = ChatSpotClient.observeLastMessageChange(success: { (roomGuid, lastMessage, lastMessageTimestamp) in
            let chatRoomWithLastMessageChange = self.chats.filter { $0.guid == roomGuid }
            if let room = chatRoomWithLastMessageChange.first {
                room.lastMessage = lastMessage
                room.lastMessageTimestamp = lastMessageTimestamp
                self.chats.sort(by: { (first, second) -> Bool in
                    first.lastMessageTimestamp ?? 0 > second.lastMessageTimestamp ?? 0
                })
                self.tableView.reloadData()
            }
        }) { (error) in
            // silent. doesn't break the feature.
        }
        
        observers.append(lastMessageObserver)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        observers.forEach { ChatSpotClient.removeObserver(handle: $0) }
        observers.removeAll()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("in prep for segue")
        if segue.identifier == "ChatRoomVCSegue"{
            let chatRoomVC = segue.destination as! ChatRoomVC
//            chatRoomVC.delegate = self
            if let cell = sender as? ChatListCell, let indexPath = tableView.indexPath(for: cell) {
                chatRoomVC.chatRoom = chats[indexPath.row]
            }
        }
    }
    func setupAndTriggerHUD(){
        KRProgressHUD.set(style: .white)
        KRProgressHUD.set(font: .systemFont(ofSize: 17))
        KRProgressHUD.set(activityIndicatorViewStyle: .gradationColor(head: UIColor.ChatSpotColors.Blue, tail: UIColor.ChatSpotColors.DarkBlue))
        KRProgressHUD.show(withMessage: "Loading ChatSpots...")
    }

	

}

// TableView Methods

extension ChatListVC: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
		//set properties of cell
		cell.chatRoom = chats[indexPath.row]
        
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return chats.count
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated:true)
	}
	
}


extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    struct ChatSpotColors {
        static let DarkBlue = UIColor(netHex: 0x172969)
        static let LightBlue = UIColor(netHex: 0x3eacec)
        static let Blue = UIColor(netHex: 0x0551be)
        static let Red = UIColor(netHex: 0xb61e23)
        static let Orange = UIColor(netHex: 0xff5f0d)
    }
}

