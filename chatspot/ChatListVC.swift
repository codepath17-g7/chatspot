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
	var chats: [ChatRoom] = [ChatRoom]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.estimatedRowHeight = 108
		tableView.rowHeight = UITableViewAutomaticDimension

        //ChatSpotClient.createChatRoom(name: "Cupertino", description: "whatupp!", banner: nil)
        
        observer = ChatSpotClient.observeChatRooms(success: { (rooms: [ChatRoom]) in
            self.chats = rooms
            self.tableView.reloadData()
            //KRProgressHUD.showSuccess()
            print(rooms)
        }, failure: {
            print("Could not find chats")
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
