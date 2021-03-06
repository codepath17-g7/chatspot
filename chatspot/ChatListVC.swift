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
	var chatrooms: [ChatRoom1] = [ChatRoom1]()
    var unreadCount = [String: Int]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.estimatedRowHeight = 160
		tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        
        setupAndTriggerHUD()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.setUpTitle(title: "Chatspots")
        tableView.backgroundColor = UIColor.ChatSpotColors.LighterGray

        if let aroundMeRoomGuid = ChatSpotClient.currentUser.aroundMe {
            updateAroundMeRoom(aroundMeRoomGuid)
        }

        self.tableView.reloadData()
        
        KRProgressHUD.dismiss()
        
        startObservingAroundMeRoomGuid()
        
        startObservingChatRoomList()
        
        startObservingLastMessage()
        
        ChatSpotClient.getUnreadCount { (unreadData) in
            self.unreadCount = unreadData
            self.sortChatRooms()
            self.tableView.reloadData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(appGoingToBackground(notification:)),
                                               name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isTranslucent = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isTranslucent = false

        observers.forEach { ChatSpotClient.removeObserver(handle: $0) }
        observers.removeAll()
    }
    
    // This is an unwind segue
    @IBAction func unwindToChatList(segue: UIStoryboardSegue) {}
    
    func updateAroundMeRoom(_ roomGuid: String?) {
        guard let roomGuid = roomGuid  else {
            if (chatrooms.count > 0 && chatrooms[0].isAroundMe) {
                print("Removing around me")
                chatrooms.remove(at: 0)
                self.tableView.reloadData()
            }
            return
        }
        
        
        print("Around me room -> \(roomGuid)")

        let aroundMeRoom = ChatRoom1()
        guard let userLocalRoom = ChatSpotClient.chatrooms[roomGuid] else {
            return;
        }
        
        aroundMeRoom.name = "Around Me"
        aroundMeRoom.guid = roomGuid
        aroundMeRoom.isAroundMe = true
        aroundMeRoom.users = userLocalRoom.users
        aroundMeRoom.localUsers = userLocalRoom.localUsers
        aroundMeRoom.lastMessage = userLocalRoom.lastMessage
        if aroundMeRoom.lastMessage.isEmpty {
            aroundMeRoom.lastMessage = "You’re the first one here!"
        }
        aroundMeRoom.lastMessageTimestamp = userLocalRoom.lastMessageTimestamp
        if (chatrooms.count > 0 && chatrooms[0].isAroundMe) {
            print("Replacing current around me room")
            chatrooms[0] = aroundMeRoom
        } else {
            print("Insert around me room")
            chatrooms.append(aroundMeRoom)
        }
        self.tableView.reloadData()
    }

    func startObservingAroundMeRoomGuid() {
        let observer = ChatSpotClient.observeMyAroundMeRoomGuid(success: { (roomGuid: String?) in
            self.updateAroundMeRoom(roomGuid)
        }) { (error: Error?) in
            
        }
        observers.append(observer)
    }
    
    func startObservingChatRoomList() {
        let chatRoomObsevers = ChatSpotClient.observeMyChatRooms(onAdd: { (room: ChatRoom1) in
            
            self.chatrooms.append(room)
            self.tableView.reloadData()
            KRProgressHUD.dismiss()
            
        }, onRemove: { (room: ChatRoom1) in
            
            var itemToRemoveIndex = -1
            for index in 1..<self.chatrooms.count {
                if (self.chatrooms[index].guid == room.guid) {
                    itemToRemoveIndex = index
                    break;
                }
            }
            
            if itemToRemoveIndex != -1 {
                self.chatrooms.remove(at: itemToRemoveIndex)
                self.tableView.reloadData()
            }
            
        }, addFailure: { (error: Error!) in
            
            print("Error in startObservingChatRoomList: \(error.localizedDescription)")
            
        }, removeFailure:  { (error: Error!) in
            
            KRProgressHUD.dismiss()
        })
        
        observers.append(contentsOf: chatRoomObsevers)
        
        let chatRoomsObservers = ChatSpotClient.observeChatRooms(success: { (room: ChatRoom1) in
            // refresh in case we have stale data
            if self.chatrooms.count > 0 && self.chatrooms[0].isAroundMe {
                self.updateAroundMeRoom(self.chatrooms[0].guid)
            }
        }) { (error) in
            
        }
        
        
        observers.append(contentsOf: chatRoomsObservers)
    }
    
    func startObservingLastMessage() {
        let lastMessageObserver = ChatSpotClient.observeLastMessageChange(success: { (roomGuid, lastMessage, lastMessageTimestamp) in
            let chatRoomsWithLastMessageChange = self.chatrooms.filter { $0.guid == roomGuid }
            for room in chatRoomsWithLastMessageChange {
                
                let unreadCountForRoom = self.unreadCount[room.guid] ?? 0
                self.unreadCount[room.guid] = unreadCountForRoom + 1
                
                room.lastMessage = lastMessage
                room.lastMessageTimestamp = lastMessageTimestamp!
                self.sortChatRooms()
                self.tableView.reloadData()
            }
        }) { (error) in
            // silent. doesn't break the feature.
        }
        
        observers.append(lastMessageObserver)
    }
    
    private func sortChatRooms() {
        self.chatrooms.sort(by: { (first, second) -> Bool in
            // Make sure that around me room is always sticky at top
            if first.isAroundMe {
                return true
            }
            
            if second.isAroundMe {
                return false
            }
            
            let firstHasUnread = (self.unreadCount[first.guid] ?? 0) > 0
            let secondHasUnread = (self.unreadCount[second.guid] ?? 0) > 0
            
            if firstHasUnread == secondHasUnread {
                return first.lastMessageTimestamp > second.lastMessageTimestamp
            }
            return firstHasUnread && !secondHasUnread
        })
    }

    
    @objc func appGoingToBackground(notification: NSNotification) {
        saveAllUnreadCounts()
    }
    
    func saveAllUnreadCounts() {
        unreadCount.forEach {
            ChatSpotClient.saveUnreadCount(forChatroom: $0, count: $1)
        }
    }
    
    func clearUnreadCount(chatroomGuid: String) {
        let count = unreadCount[chatroomGuid]
        if  count != nil && count! > 0 {
            unreadCount[chatroomGuid] = 0
            ChatSpotClient.saveUnreadCount(forChatroom: chatroomGuid, count: 0)
            sortChatRooms()
            tableView.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("in prep for segue")
        if segue.identifier == "ChatRoomVCSegue"{
            let chatRoomVC = segue.destination as! ChatRoomVC
//            chatRoomVC.delegate = self
            if let cell = sender as? ChatListCell, let indexPath = tableView.indexPath(for: cell) {
                chatRoomVC.chatRoom = chatrooms[indexPath.row]
            }
        }
    }
    
    func setupAndTriggerHUD(){
        KRProgressHUD.set(style: .white)
        KRProgressHUD.set(font: .systemFont(ofSize: 17))
        KRProgressHUD.set(activityIndicatorViewStyle: .gradationColor(head: UIColor.ChatSpotColors.PastelRed, tail: UIColor.ChatSpotColors.SelectedBlue))
        KRProgressHUD.show(withMessage: "Loading Chatspots...")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

// TableView Methods

extension ChatListVC: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
		//set properties of cell
        let chatroom = chatrooms[indexPath.row]
        cell.contentView.backgroundColor = tableView.backgroundColor
		cell.chatRoom = chatroom
        cell.unreadCount = unreadCount[chatroom.guid!] ?? 0
        cell.selectionStyle = .none
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return chatrooms.count
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let selectedChatroomGuid = chatrooms[index].guid!
        clearUnreadCount(chatroomGuid: selectedChatroomGuid)
        
		tableView.deselectRow(at: indexPath, animated:true)
	}
	
}

//MARK: ============ Object Extensions ============

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
        
        static let SelectedBlue = UIColor(netHex: 0x2ABAE8)
        static let DarkerSelectedBlue = UIColor(netHex: 0x0386b1)
        static let DarkestSelectedBlue = UIColor(netHex: 0x0e7597)
        static let PastelRed = UIColor(netHex: 0xFF5858)
        static let BrightPink = UIColor(netHex: 0xFF5AA2)
        static let LightestGray = UIColor(netHex: 0xFAFAFA)
        static let LighterGray = UIColor(netHex: 0xF1F1F1)
        static let LightGray = UIColor.lightGray
        
    }
}

extension UINavigationItem {
    
    func setUpTitle(title: String){
        let titleLabel = UILabel()
        let titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont.Chatspot.extraLarge]
        titleLabel.attributedText = NSAttributedString(string: title, attributes: titleTextAttributes)
        titleLabel.sizeToFit()
        let leftItem = UIBarButtonItem(customView: titleLabel)
        self.leftBarButtonItem = leftItem
    }
}

extension UIImage {
    
    var roundedCorners: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: 7.0
            ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    // create a UIImage of just one solid color
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension UIFont {
    
    struct AppSizes {
        static let extraLarge: CGFloat = 28.0
        static let larger: CGFloat = 20.0
        static let large: CGFloat = 18.0
        static let regular: CGFloat = 17.0
        static let small: CGFloat = 14.0
    }
    
    struct AppFonts {
        static let regular = "SFProText-Regular"
        static let bold = "SFProText-Bold"
        static let medium = "SFProText-Medium"
        static let semibold = "SFProText-Semibold"
        
        static let bigRegular = "SFProDisplay-Regular"
        static let bigBold = "SFProDisplay-Bold"
        static let bigMedium = "SFProDisplay-Medium"
        static let bigSemibold = "SFProDisplay-Semibold"
        
    }
    
    struct Chatspot {
        static let extraLarge = UIFont(name: AppFonts.bigBold, size: AppSizes.extraLarge)!
        static let large = UIFont(name: AppFonts.bold, size: AppSizes.large)!
        static let regular = UIFont(name: AppFonts.regular, size: AppSizes.regular)!
        static let small = UIFont(name: AppFonts.regular, size: AppSizes.small)!
        
        static let regularNavigationTitle = UIFont(name: AppFonts.semibold, size: AppSizes.regular)!
    }
}


extension UIImageView {
    func changeToColor(color: UIColor){
        self.image = self.image!.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
}

extension UIButton {
    func changeImageViewTo(color: UIColor){
        let orginalImage = self.imageView?.image
        let newColorImage = orginalImage?.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
        self.setImage(newColorImage, for: .normal)
//        self.tintColor = color
    }
}


