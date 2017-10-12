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
		tableView.estimatedRowHeight = 120
		tableView.rowHeight = UITableViewAutomaticDimension

		self.chats = [ChatRoom()]
// Function to populate array of chats
		
//		ChatSpotClient.sharedInstance.someFunctionToGetMyCurrentChats(someParam: Stringorsomething, success: { (chats: [Chat]) in
//			self.chats = chats
//			self.tableView.reloadData()
//			KRProgressHUD.showSuccess()
//		}, failure: { (error: Error) in
//			print("Could not find chats: \(error.localizedDescription)")
//		})

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
