//
//  AroundMeVC.swift
//  chatspot
//
//  Created by Eden on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class AroundMeVC: UIViewController {

    @IBOutlet weak var aroundMeView: AroundMeView!
    var observer: UInt!
    var chats: [String: ChatRoom1] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
//
//        observer = ChatSpotClient.observeChatRooms(success: { (room: ChatRoom1) in
//            self.chats[room.guid] = room
//            self.aroundMeView.updateRooms(Array(self.chats.values))
//        }, failure: { (error: Error?) in
//            print(error ?? "")
//        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        ChatSpotClient.removeObserver(handle: observer)
    }

}
