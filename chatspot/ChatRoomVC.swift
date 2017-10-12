//
//  ChatRoomVC.swift
//  chatspot
//
//  Created by Eden on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class ChatRoomVC: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	var messages: [Message] = [Message]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.estimatedRowHeight = 120
		tableView.rowHeight = UITableViewAutomaticDimension
		
		// Function to populate array of chatroom messages
		//		ChatSpotClient.sharedInstance.someFunctionToGetChatRoomMessages(someParam: Stringorsomething, success: { (messages: [Message]) in
		//			self.messages = chats
		//			self.tableView.reloadData()
		//			KRProgressHUD.showSuccess()
		//		}, failure: { (error: Error) in
		//			print("Could not find chats: \(error.localizedDescription)")
		//		})
		
		
    }
	
	

}


// TableView Methods

extension ChatRoomVC: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell") as! ChatMessageCell
		//set properties of cell
		cell.message = messages[indexPath.row]
		cell.selectionStyle = UITableViewCellSelectionStyle.none
		//TODO: set cell delegate

		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messages.count
	}
	
}
