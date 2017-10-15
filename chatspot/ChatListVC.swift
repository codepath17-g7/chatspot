//
//  ChatListVC.swift
//  chatspot
//
//  Created by Eden on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class ChatListVC: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
    var observer: UInt!
	var chats: [ChatRoom1] = [ChatRoom1]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.estimatedRowHeight = 108
		tableView.rowHeight = UITableViewAutomaticDimension

        // Uncomment to add rooms for testing statically
        //ChatSpotClient.createChatRoom(name: "Cupertino", description: "whatupp!", banner: nil)
//        ChatSpotClient.createChatRoom(name: "Oracle Arena", description: "Warriors!", banner: nil, longitude: 37.750278, latitude: -122.203056)
//        ChatSpotClient.createChatRoom(name: "Golden Gate Bridge", description: "San Francisco, California", banner: nil, longitude: 37.819722, latitude: -122.478611)
//        ChatSpotClient.createChatRoom(name: "SAP Center", description: "Sharks", banner: nil, longitude: 37.332778, latitude: -121.901111)
        
        
        startObservingChatRoomList()
    }
    
    func startObservingChatRoomList() {
        observer = ChatSpotClient.observeMyChatRooms(success: { (room: ChatRoom1) in
            self.chats.append(room)
            self.tableView.reloadData()
            //KRProgressHUD.showSuccess()
        }, failure: { (error: Error?) in
            print(error)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ChatSpotClient.removeObserver(handle: observer)
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
