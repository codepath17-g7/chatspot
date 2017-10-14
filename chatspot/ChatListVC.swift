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
	var chats: [ChatRoom] = [ChatRoom]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.estimatedRowHeight = 108
		tableView.rowHeight = UITableViewAutomaticDimension

		setupMockChatList()
// Function to populate array of chats
		
//		ChatSpotClient.sharedInstance.someFunctionToGetMyCurrentChats(someParam: Stringorsomething, success: { (chats: [Chat]) in
//			self.chats = chats
//			self.tableView.reloadData()
//			KRProgressHUD.showSuccess()
//		}, failure: { (error: Error) in
//			print("Could not find chats: \(error.localizedDescription)")
//		})

    }
	
    func setupMockChatList(){
        let chatroom1 = ChatRoom(guid: "234cdwf", createdAt: 123432254, name: "Oracle Arena")
        let chatroom2 = ChatRoom(guid: "234cfffdwf", createdAt: 1234334532254, name: "Rengstorff Park")
        self.chats = [chatroom1, chatroom2]
        self.tableView.reloadData()
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
