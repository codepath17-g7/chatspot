//
//  ChatRoomVC.swift
//  chatspot
//
//  Created by Eden on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase
import MBProgressHUD
import ISEmojiView
import GrowingTextView
import ImagePickerSheetController
import Photos
import Haneke
import PureLayout

class ChatRoomVC: UIViewController, ChatMessageCellDelegate, UITextFieldDelegate {
    static var MAX_MESSAGES_LIMIT: UInt = 10
    
	@IBOutlet weak var containerView: UIView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var addPhotoButton: UIButton!
	@IBOutlet weak var addEmojiButton: UIButton!
    @IBOutlet weak var addActivityButton: UIButton!
	@IBOutlet weak var messageTextView: GrowingTextView!
	@IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var chatRoomNameLabel: UILabel!
    @IBOutlet weak var chatRoomMemberCountLabel: UILabel!
    @IBOutlet weak var toolbarView: UIView!  
    @IBOutlet weak var containerTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    var activityView: ActivityView!
    var currentActivity: Activity?
    
	var loadingMoreView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var isLoading = false
	var messages: [Message1] = [Message1]()
    var chatRoom: ChatRoom1!
	var initialY: CGFloat!
    var toolbarInitialY: CGFloat!
    var observers = [UInt]()
    let imageCache = Shared.imageCache

    
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.estimatedRowHeight = 50
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.separatorStyle = .none
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        extendedLayoutIncludesOpaqueBars = true
        
        // Set up the keyboard to move appropriately
		setUpKeyboardNotifications()
		
        // UI setup
        setUpUI()
        
        self.startObservingMessages()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isTranslucent = false

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isTranslucent = true

        if chatRoom.guid == nil {
            print("Not attached to a room")
            return
        }

        observers.forEach { ChatSpotClient.removeObserver(handle: $0) }
        observers.removeAll()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "chatroomDetailSegue") {
            let detailVC = segue.destination as! ChatRoomDetailVC
            detailVC.chatroom = self.chatRoom
//            let navigationVC = segue.destination as! UINavigationController
//            let destinationVC = navigationVC.topViewController as! ChatRoomDetailVC
//            destinationVC.chatroom =
        }
    }
    
//MARK: ============ Initial Setup Methods ============
    
    private func onNewMessage(_ message: Message1) {
        print(message)
        self.messages.insert(message, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    private func startObservingMessages() {
        if chatRoom.guid == nil {
            print("Not attached to a room")
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            if self.chatRoom.isAroundMe {
                self.observers.append(ChatSpotClient.observeNewMessagesAroundMe(limit: ChatRoomVC.MAX_MESSAGES_LIMIT, success: { (message: Message1) in
                    DispatchQueue.main.async {
                        self.onNewMessage(message)
                    }
                }, failure: {
                    DispatchQueue.main.async {
                        print("Error in observeNewMessages")
                    }
                }))
                

                self.observers.append(ChatSpotClient.observeMyAroundMeRoomGuid(success: { (roomGuid: String?) in
                    guard let roomGuid = roomGuid else {
                        return
                    }
                    print("Chat room -> \(roomGuid)")
                    self.chatRoom.guid = roomGuid
//                    self.chatRoom.name = "Around Me"
//                    DispatchQueue.main.async {
//                        self.setRoomName(self.chatRoom.name)
//                    }
                }, failure: { (error: Error?) in
                    DispatchQueue.main.async {
                    }
                }))

            } else {
                self.observers.append(ChatSpotClient.observeNewMessages(
                    roomId: self.chatRoom.guid,
                    limit: ChatRoomVC.MAX_MESSAGES_LIMIT,
                    success: { (message: Message1) in
                        DispatchQueue.main.async {
                            self.onNewMessage(message)
                        }
                }, failure: {
                    DispatchQueue.main.async {
                        print("Error in observeNewMessages")
                    }
                }))
                
                /*ChatSpotClient.getMessagesForRoom(roomId: self.chatRoom.guid, limit: ChatRoomVC.MAX_MESSAGES_LIMIT, lastMsgId: "", success: { (messages: [Message1]) in
                    self.messages = messages
                    self.tableView.reloadData()
                    self.isLoading = false
                    MBProgressHUD.hide(for: self.view, animated: true)
                }, failure: { (error: Error?) in
                    self.isLoading = false
                    MBProgressHUD.hide(for: self.view, animated: true)
                })*/
            }
            
            // MARK: Activity
//            let user = ChatSpotClient.currentUser
//            let a = Activity(activityName: "Volleyball", activityStartedByName: user!.name!, activityStartedByGuid: user!.guid!, latitude: self.chatRoom.latitude , longitude: self.chatRoom.longitude)
//            
//            ChatSpotClient.createActivtyForChatRoom(roomGuid: self.chatRoom.guid, activity: a, success: {
//                print("Activity Created")
//            }, failure: {
//                print("Error creating activity")
//            })
            
            let activityObsevers = ChatSpotClient.listenForActivities(roomGuid: self.chatRoom.guid, onStartActivity: { (activity) in
                DispatchQueue.main.async {
                    if (self.activityView == nil) {
                        self.activityView = ActivityView()
                        self.activityView.loadFromXib()
                    }
                    
                    if (self.activityView.superview == nil) {
                        self.view.addSubview(self.activityView)
                        let inset = self.navigationController!.navigationBar.frame.height + 20
                        self.activityView.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: inset)
                        self.activityView.autoPinEdge(toSuperviewEdge: ALEdge.left)
                        self.activityView.autoPinEdge(toSuperviewEdge: ALEdge.right)
                        self.activityView.autoSetDimension(ALDimension.height, toSize: 50.0)
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onActivityBannerTapped(_:)))
                        self.activityView.addGestureRecognizer(tapGesture)
                    }
                    
                    self.currentActivity = activity
                    self.activityView.activityInfoText.text = "\(activity.activityStartedByName!) started \(activity.activityName!)"
                }
            }, onUpdateActivity: { (activity) in
                
                self.currentActivity = activity
                
            }, onEndActivity: { (activity) in
                DispatchQueue.main.async {
                    if (self.activityView.superview != nil) {
                        self.activityView.removeFromSuperview()
                    }
                }
            })
            self.observers.append(contentsOf: activityObsevers)
        }
    }
    
    func onActivityBannerTapped(_ sender: UIView) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier: "activityDetailNavigationController") as! UINavigationController
        let activityDetailVC = navigationController.topViewController as! ActivityDetailVC
        activityDetailVC.activity = currentActivity
        activityDetailVC.roomGuid = chatRoom.guid
        present(navigationController, animated: true)
    }

//    func setUpInfiniteScrolling(){
////        let tableFooterView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
//
////        self.tableView.tableFooterView = tableFooterView
//    }
//    
	
    func setRoomName (_ roomName: String) {
        chatRoomNameLabel.attributedText = NSAttributedString(string: roomName, attributes: [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont.Chatspot.regularNavigationTitle])
        messageTextView.attributedPlaceHolder = NSAttributedString(string: "Message \(roomName)", attributes: [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.Chatspot.regular])

    }
    
	func setUpUI(){
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        setRoomName(chatRoom.name)
        
        let userCount = chatRoom.isAroundMe ? chatRoom.localUsers?.count : chatRoom.users?.count
        
        if let memberCount = userCount {
            let attributes = [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont.Chatspot.small]
            
            if memberCount == 1 {
                chatRoomMemberCountLabel.attributedText = NSAttributedString(string: "You're the first one here!", attributes: attributes)
            } else {
                let pluralAdjustment = memberCount == 1 ? "member" : "members"
                chatRoomMemberCountLabel.attributedText = NSAttributedString(string: "\(memberCount) \(pluralAdjustment)", attributes: attributes)
            }
            
        }

        addEmojiButton.setImage(addEmojiButton.imageView?.image, for: .selected)
        addPhotoButton.setImage(addPhotoButton.imageView?.image, for: .selected)
        addActivityButton.setImage(addActivityButton.imageView?.image, for: .selected)
		addPhotoButton.changeImageViewTo(color: .lightGray)
		addEmojiButton.changeImageViewTo(color: .lightGray)
        addActivityButton.changeImageViewTo(color: .lightGray)
        
		messageTextView.autoresizingMask = .flexibleWidth
        messageTextView.maxLength = 300
        messageTextView.trimWhiteSpaceWhenEndEditing = false
        messageTextView.layer.cornerRadius = 7.0
        messageTextView.clipsToBounds = true
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.borderColor = UIColor.ChatSpotColors.LighterGray.cgColor
        
        // maybe add these back
//        toolbarView.layer.borderWidth = 0.3
//        toolbarView.layer.borderColor = UIColor.ChatSpotColors.LightGray.cgColor
        sendMessageButton.setAttributedTitle(NSAttributedString(string: "Send", attributes:[NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.Chatspot.regularNavigationTitle]), for: .disabled)
        sendMessageButton.setAttributedTitle(NSAttributedString(string: "Send", attributes: [NSForegroundColorAttributeName: UIColor.ChatSpotColors.SelectedBlue, NSFontAttributeName: UIFont.Chatspot.regularNavigationTitle])
, for: .normal)
        sendMessageButton.isEnabled = false
        
        // create and add an info button in the navigation bar that links to chatroom details
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(openChatroomDetailScreen), for: .touchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = infoBarButtonItem
        
        
        
        DispatchQueue.global(qos: .userInitiated).async {
        
            var roomBanner: UIImage?
            if let urlString = self.chatRoom.banner,
                let url = URL(string: urlString),
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data) {
                roomBanner = image
            }
            
            guard let bannerImage = roomBanner else {
                print("no banner image")
                return
            }
            
            let footerView = ParallaxView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 120), image: bannerImage)
            self.loadingMoreView.center = footerView.center
            footerView.insertSubview(self.loadingMoreView, at: 0)
            
            DispatchQueue.main.async {
                self.tableView.tableFooterView = footerView
                self.tableView.tableFooterView!.transform = self.tableView.transform
            }
        }
    }
    
    @objc private func openChatroomDetailScreen() {
        performSegue(withIdentifier: "chatroomDetailSegue", sender: self)
    }
	
	func setUpKeyboardNotifications(){
        
        initialY = containerTopMarginConstraint.constant
        toolbarInitialY = toolbarBottomConstraint.constant
        
		NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { (notification: Notification) in
            
			let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
			let keyboardHeight = frame.size.height
            
            if self.needToMoveContainerView(keyboardHeight: keyboardHeight){
                self.containerTopMarginConstraint.constant = self.initialY - keyboardHeight
                self.adjustViewsForKeyboardMove(notification: notification)

            } else {
                self.toolbarBottomConstraint.constant = self.toolbarInitialY + keyboardHeight
                self.adjustViewsForKeyboardMove(notification: notification)
            }
		}
        
		NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { (notification: Notification) in
            
            self.containerTopMarginConstraint.constant = self.initialY
            self.toolbarBottomConstraint.constant = self.toolbarInitialY
            self.adjustViewsForKeyboardMove(notification: notification)
		}
	}
    
    func adjustViewsForKeyboardMove(notification: Notification){
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
        
        UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: [UIViewAnimationOptions(rawValue: UInt(curve))], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func needToMoveContainerView(keyboardHeight: CGFloat) -> Bool {
        var indexPath: IndexPath
        if self.messages.count == 0 {
            indexPath = IndexPath(row: 0, section: 0)
        } else {
            indexPath = IndexPath(row: self.messages.count - 1, section: 0)
        }
        let frameForRow = self.tableView.rectForRow(at: indexPath)
        let rectOfRowInSuperview = self.tableView.convert(frameForRow, to: self.tableView.superview)
        if rectOfRowInSuperview.maxY > (self.view.frame.height - keyboardHeight){
            return true
        }
        return false
    }

    
//MARK: ============ User Interaction Methods ============

    
	@IBAction func didTapAwayFromKeyboard(_ sender: UITapGestureRecognizer) {
		view.endEditing(true)
	}
    
    @IBAction func onAddActivity(_ sender: UIButton) {
        print("Add activity tapped.")
        
        var observer: Any?
        
        let alertController = UIAlertController(title: "Start an Activity!", message: "Enter an activity name to get started.", preferredStyle: .alert)
        
        let goAction = UIAlertAction(title: "Go!", style: .default) { (_) in
            if let field = alertController.textFields?[0],
                let descriptionField = alertController.textFields?[1] {
                // store your data
                print("creatig activity \(field.text!)")
                let user = ChatSpotClient.currentUser!
                let activity = Activity(activityName: field.text!, activityDescription: descriptionField.text ?? "", activityStartedByName: user.name!, activityStartedByGuid: user.guid!, latitude: self.chatRoom.latitude, longitude: self.chatRoom.longitude)
                
                ChatSpotClient.createActivtyForChatRoom(roomGuid: self.chatRoom.guid, activity: activity, success: {
                    print("Activity created")
                }){}
            }
            
            NotificationCenter.default.removeObserver(observer!)
        }
        goAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            NotificationCenter.default.removeObserver(observer!)
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Activity name"
            textField.delegate = self
            observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                goAction.isEnabled = textField.text!.characters.count > 0
            }
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Short description"
        }
        
        alertController.addAction(goAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if ((textField.text?.characters.count ?? 0) >= 20 && range.length == 0) {
            return false
        }
        return true
    }
    
    @IBAction func addEmojiButtonClicked(_ sender: Any) {
        if addEmojiButton.isSelected {
            addEmojiButton.isSelected = false
            messageTextView.inputView = nil
        } else {
            addEmojiButton.isSelected = true
            let emojiView = ISEmojiView()
            emojiView.delegate = self
            messageTextView.inputView = emojiView
            messageTextView.becomeFirstResponder()
        }
        messageTextView.reloadInputViews()
    }
    
    
    @IBAction func addPhotoButtonClicked(_ sender: AnyObject) {
        addPhotoButton.isSelected = true
        openImagePickerActionSheet()
    }
    
    
    @IBAction func sendMessageButtonClicked(_ sender: UIButton) {
        if chatRoom.guid == nil {
            return
        }
        if !(messageTextView.text?.isEmpty)! {
            
            let tm = Message1(roomId: chatRoom.guid, message: messageTextView.text!, name: ChatSpotClient.currentUser.name!, userGuid: ChatSpotClient.currentUser.guid!)

            ChatSpotClient.sendMessage(message: tm, room: chatRoom, success: {
                self.messageTextView.text = ""
                self.sendMessageButton.isEnabled = false
                print("message sent!")
                
            }, failure: {
                print("message sending failed")
            })
        }
        
    }
    
    
    
//MARK: ============ MessageCellDelegate Methods ============
    
    func presentAlertViewController(alertController: UIAlertController){
        self.present(alertController, animated: true)
    }
    
    func sendPrivateMessageTo(userID: String){
    }
    
    func viewUserProfile(userID: String){
        
    }
}

//MARK: ============ TableView Methods ============

extension ChatRoomVC: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        if message.system {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpecialAroundMeCell") as! SpecialAroundMeCell
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.locationChangeLabel.text = message.message!
            return cell
        }
        
		let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell") as! ChatMessageCell
        
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
		//set properties of cell
		cell.message = message
		cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.delegate = self
        // check if previous message was by the same person:
        if indexPath.row > 0 {
            let previousMessage = messages[indexPath.row - 1]
            if let prevAuthor = previousMessage.name, let currAuthor = message.name {
                if currAuthor == prevAuthor {
                    cell.sameAuthor = true
                } else {
                    cell.sameAuthor = false
                }
            } else {
                cell.sameAuthor = false
            }
        } else {
            cell.sameAuthor = false
        }

		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messages.count
	}
}

//MARK: ============ TextView Delegate Methods ============
extension ChatRoomVC: GrowingTextViewDelegate {
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidChange(_ textView: GrowingTextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.sendMessageButton.isEnabled = false
        } else {
            
            self.sendMessageButton.isEnabled = true
        }
    }
}

//MARK: ============ ImagePicker Methods ============

extension ChatRoomVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImagePickerSheetControllerDelegate {
    
    func openImagePickerActionSheet() {
        
        // Backup plan of going to camera or camera roll if desired image not shown in action sheet
        let presentImagePickerController: (UIImagePickerControllerSourceType) -> () = { source in
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.allowsEditing = true
            var sourceType = source
            if !UIImagePickerController.isSourceTypeAvailable(sourceType) {
                sourceType = .photoLibrary
                print("Fallback to camera roll as a source since the simulator doesn't support taking pictures")
            }
            controller.sourceType = sourceType
            
            // Present camera or full photo gallery
            self.present(controller, animated: true, completion: nil)
        }
        
        
        // Action sheet controller setup:
        let controller = ImagePickerSheetController(mediaType: .imageAndVideo)
        controller.delegate = self

        // Add "Take Photo or Video" and "Add caption" buttons
        controller.addAction(ImagePickerAction(title: NSLocalizedString("Take Photo or Video", comment: "Action Title"), secondaryTitle: NSLocalizedString("Add caption", comment: "Action Title"), handler: { _ in
            
            presentImagePickerController(.camera)
            
        }, secondaryHandler: { _, numberOfPhotos in
            
            print("Caption \(numberOfPhotos) photos")
            
        }))
        
        // Add "Photo Library" and "Send photos" buttons
        controller.addAction(ImagePickerAction(title: NSLocalizedString("Photo Library", comment: "Action Title"), secondaryTitle: { NSString.localizedStringWithFormat(NSLocalizedString("ImagePickerSheet.button1.Send %lu Photo", comment: "Action Title") as NSString, $0) as String}, handler: { _ in
            
            presentImagePickerController(.photoLibrary)
            
        }, secondaryHandler: { _, numberOfPhotos in
            
            // gets the images/videos for the assets selected from the imagepickeractionsheet
            self.getMediaForAssets(selectedAssets: controller.selectedAssets)
            
        }))

        // Add "Cancel" button
        controller.addAction(ImagePickerAction(cancelTitle: NSLocalizedString("Cancel", comment: "Action Title"), handler: { _ in
            
            self.addPhotoButton.isSelected = false

        }))
        
        // Presentation for different devices
        if UIDevice.current.userInterfaceIdiom == .pad {
            controller.modalPresentationStyle = .popover
            controller.popoverPresentationController?.sourceView = view
            controller.popoverPresentationController?.sourceRect = CGRect(origin: view.center, size: CGSize())
        }
        
        // Present ImagePickerActionSheet
        present(controller, animated: true, completion: nil)
    }
    
    
//    here's what i'm doing so far in the below methods:
//
//    once user has selected however many photos they want to send, and they click send, getMediaForAssets gets called on those assets
//    method getFullImageForAsset retrieves the full-size image for that asset. (there's also getSmallImageForAsset and getVideoForAsset)
//    call storeage client method to store the file, which returns a url
//    cache the file locally in the Haneke shared cache
//    send message with the urlstring as the attachment
//    in the custom message cell class, retrieve image from cache and display it
    


    // Gets the images/videos for the selected assets (imagepickeractionsheet)
    func getMediaForAssets(selectedAssets: [PHAsset]){
        //for every asset in the asset array
        for asset in selectedAssets {
            
            if asset.mediaType == .image {
                //retrieve full size image for that asset
                asset.getFullImage(completion: { (image: UIImage?) in
                    if let img = image {
                        self.storeAndSendImage(image: img, asset: asset)
                    }
                })
                
            } else if asset.mediaType == .video {
                
                let taskGroup = DispatchGroup()
                var thumbImage: UIImage?
                var videoUrl: URL?
                
                taskGroup.enter()
                asset.getSmallImage(completion: { (newThumbImage: UIImage?) in
                    thumbImage = newThumbImage
                    taskGroup.leave()
                })
                
                taskGroup.enter()
                asset.getURL(completionHandler: { (newURL: URL?) in
                    videoUrl = newURL
                    taskGroup.leave()
                })
                
                taskGroup.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
                    if thumbImage != nil && videoUrl != nil {
                        StorageClient.instance.storeChatVideo(videoThumb: thumbImage!, inputVideoUrl: videoUrl!, success: { (storedThumbUrl: URL?, storedVideoURL: URL?) in
                            print("Stored thumb \(storedThumbUrl!.absoluteString) video \(storedVideoURL!.absoluteString)")
                            
                            self.imageCache.set(value: thumbImage!, key: storedThumbUrl!.absoluteString)

                            let videoMessage = Message1(roomId: self.chatRoom.guid, message: "", name: ChatSpotClient.currentUser.name!, userGuid: ChatSpotClient.currentUser.guid!, attachment: nil)
                            videoMessage.mediaFileUrl = storedVideoURL!.absoluteString
                            videoMessage.thumbnailImageUrl = storedThumbUrl!.absoluteString
                            videoMessage.mediaType = PHAssetMediaType.video.rawValue
                            
                            ChatSpotClient.sendMessage(message: videoMessage, room: self.chatRoom, success: {
                                print("video sent!")
                            }, failure: {
                                print("video sending failed")
                            })
                            
                        }, failure: {
                            print("Failed to store videos and thumbs")
                        })
                    }
                }))
//                //retrieve video
//                getVideoForAsset(asset: asset, completion: { (video: AVPlayerItem?) in
//                    if let vid = video {
//                    
//                        // make method to store and send video
//                    }
//                })

            }
        }
    }
    
    func storeAndSendImage(image: UIImage, asset: PHAsset?){
        
        //store asset in firebase by calling storeChatImage on UIImage
        StorageClient.instance.storeRegularImage(chatImage: image, success: { (returnURL: URL?) in
            if let url = returnURL {
                
                let attachmentString = url.absoluteString
                print("attachmentString:")
                print(attachmentString)
                //cache image
                self.imageCache.set(value: image, key: attachmentString)
                
                //send message with string of imageURL in it
                let tm = Message1(roomId: self.chatRoom.guid, message: "", name: ChatSpotClient.currentUser.name!, userGuid: ChatSpotClient.currentUser.guid!, attachment: attachmentString)
                
                
                ChatSpotClient.sendMessage(message: tm, room: self.chatRoom, success: {
                    print("photo sent!")
                    
                }, failure: {
                    print("photo sending failed")
                })

                self.addPhotoButton.isSelected = false
                
            } else {
                "there was an issue with the returnURL"
            }
        }, failure: {
            print("Failure trying to store images")
        })

    }
    
    func getVideoForAsset(asset: PHAsset, completion: @escaping (AVPlayerItem?) -> Void ) {
        let manager = PHImageManager.default()
        let options = PHVideoRequestOptions()
//        options.progressHandler
        options.deliveryMode = .fastFormat
        options.version = .current
        manager.requestPlayerItem(forVideo: asset, options: options) { (playerItem: AVPlayerItem?, _) in
            if let vid = playerItem {
                completion(vid)
            } else {
                completion(nil)
            }
        }
    }
    
    
    
    
    
    // Regular ImagePickerController methods (in case user chooses to look through all their photos):
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        var image: UIImage
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = editedImage
        } else {
            let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            image = originalImage
        }

        picker.dismiss(animated: true, completion: { () in
            self.storeAndSendImage(image: image, asset: nil)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: {() in self.addPhotoButton.isSelected = false })
    }
    
}
//MARK: ============ ScrollView Delegate Methods ============

extension ChatRoomVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!self.isLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                loadMoreMessages()
            }
        }
        
//        if let footerView = self.tableView.tableFooterView as? ParallaxView {
//            print("tfv is a parallax view")
//            footerView.scrollViewDidScroll(scrollView: scrollView)
//        } else {
//            print("no parallax")
//
//        }
    }
    
    // TODO - fix me
    private func loadMoreMessages(){
        if chatRoom.guid == nil{
            print("Not attached to a room")
            return
        }
        
        print("SCROLLING - load more")
        if chatRoom.isAroundMe {
            self.isLoading = true;
            self.loadingMoreView.startAnimating()
            ChatSpotClient.getMessagesAroundMe(limit: UInt(ChatRoomVC.MAX_MESSAGES_LIMIT), lastMsgId: (messages.last?.guid)!, success: { (messages: [Message1]) in
                //var newMsgs: [Message1] = messages
                //newMsgs += self.messages
                if messages.count > 0 {
                    self.messages += messages
                    self.tableView.reloadData()
                }
                self.isLoading = false;
                self.loadingMoreView.stopAnimating()
            }, failure: { (e: Error?) in
                print("Failure to load old messages: \(String(describing: e?.localizedDescription))")
                self.isLoading = false;
                self.loadingMoreView.stopAnimating()
            })
            return
        } else {
            self.isLoading = true;
            self.loadingMoreView.startAnimating()
            ChatSpotClient.getMessagesForRoom(roomId: chatRoom.guid,
                                              limit: UInt(ChatRoomVC.MAX_MESSAGES_LIMIT),
                                              lastMsgId: (messages.last?.guid)!,
                                              success: { (messages: [Message1]) in
                //var newMsgs: [Message1] = messages
                //newMsgs += self.messages
                if messages.count > 0 {

                    self.messages += messages
                    self.tableView.reloadData()
                }
            
                self.isLoading = false;
                self.loadingMoreView.stopAnimating()
            }) { (e: Error?) in
                print("Failure to load old messages: \(String(describing: e?.localizedDescription))")
                self.isLoading = false;
                self.loadingMoreView.stopAnimating()
            }
        }
    }
}
 

//MARK: ============ Emoji Delegate Methods ============

extension ChatRoomVC: ISEmojiViewDelegate {
    
    // callback when tap a emoji on keyboard
    func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: String) {
        messageTextView.insertText(emoji)
    }
    
    // callback when tap delete button on keyboard
    func emojiViewDidPressDeleteButton(emojiView: ISEmojiView) {
        messageTextView.deleteBackward()
    }
    
}


//MARK: ============ Object Extensions ============

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
		self.setImage(newColorImage, for: .normal)
		self.tintColor = color
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
}
