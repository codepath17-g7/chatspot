//
//  BottomDrawerVC.swift
//  chatspot
//
//  Created by Eden on 10/31/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit
import FirebaseAuthUI


class BottomDrawerVC: UIViewController {
    var mainFullVC: ChatRoomDetailVC!
    var smallDrawerView: ChatroomCardView!

    let partialViewTopY = UIScreen.main.bounds.height - 139
    let fullViewTopY = UIScreen.main.bounds.minY
    var open = false
    var joinButt: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isUserInteractionEnabled = true
        
        self.view.addSubview(mainFullVC.view)
        self.view.addSubview(smallDrawerView)
//        self.view.bringSubview(toFront: smallDrawerView)
        self.mainFullVC.view.isHidden = true
        self.smallDrawerView.isUserInteractionEnabled = true
//        self.view.bringSubview(toFront: self.smallDrawerView.joinButton)
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture))
        gesture.delegate = self
        
        view.addGestureRecognizer(gesture)
        
        joinButt = UIButton(frame: CGRect(x: 329, y: 23, width: 30, height: 30))
        joinButt.setImage(#imageLiteral(resourceName: "pink plus button"), for: .normal)
        joinButt.setRadiusWithShadow()
        joinButt.addTarget(self, action: #selector(joinClicked), for: .touchUpInside)
        self.view.addSubview(joinButt)
//        self.smallDrawerView.bringSubview(toFront: joinButt)
        
        
        
        
        if self.smallDrawerView.chatRoom.users?.index(forKey: ChatSpotClient.userGuid) != nil {
            joinButt.isHidden = true
        } else {
            joinButt.isHidden = false
            self.view.bringSubview(toFront: smallDrawerView)

            self.view.bringSubview(toFront: joinButt)
            
        }
        self.view.layoutIfNeeded()
//        self.updateConstraints()

        
        
    }
    func joinClicked(){
        let chatRoom = self.smallDrawerView.chatRoom!
        print("joining room \(chatRoom.guid)")
        let user = Auth.auth().currentUser!
        ChatSpotClient.joinChatRoom(userGuid: user.uid, roomGuid: chatRoom.guid!)
        joinButt!.setImage(#imageLiteral(resourceName: "blue check button"), for: .selected)
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.joinButt.isSelected = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        var tabBarFrame = self.tabBarController?.tabBar.frame
//        tabBarFrame?.origin.y = self.view.frame.size.height + (tabBarFrame?.size.height)!
//        self.tabBarController?.tabBar.frame = tabBarFrame!
//        self.tabBarController?.tabBar.isEnabled = false
        // do this only for map pin click
        UIView.animate(withDuration: 0.3) { () in
            self.tabBarController?.tabBar.layer.zPosition = (self.view.layer.zPosition) - 50
            self.tabBarController?.tabBar.isHidden = true
            self.parent!.tabBarController?.tabBar.isHidden = true
            self.tabBarController?.tabBar.isUserInteractionEnabled = false
            
            // set up initial short height for partial view
            let frame = self.view.frame
            self.view.frame.origin.y = self.partialViewTopY
        }
//        self.view.bringSubview(toFront: smallDrawerView)
        self.mainFullVC.view.isHidden = true
        self.smallDrawerView.isUserInteractionEnabled = true
//        self.view.bringSubview(toFront: self.smallDrawerView.joinButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        var tabBarFrame = self.tabBarController?.tabBar.frame
//        tabBarFrame?.origin.y = self.view.frame.size.height - (tabBarFrame?.size.height)!
//        self.tabBarController?.tabBar.frame = tabBarFrame!

        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            print("animation called!!!!!")
            let frame = self?.view.frame
            self?.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: frame!.width, height: frame!.height)
            }, completion: { (finished: Bool) in
                self.mainFullVC.view.removeFromSuperview()
                self.smallDrawerView.removeFromSuperview()
                self.joinButt.removeFromSuperview()

            })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.layer.zPosition = 0
        self.tabBarController?.tabBar.isHidden = false
        self.parent?.tabBarController?.tabBar.isHidden = false

        self.tabBarController?.tabBar.isUserInteractionEnabled = true


//        UIView.animate(withDuration: 0.3) { [weak self] in
//            self?.tabBarController?.tabBar.layer.zPosition = 0
//        }
    }
    
    

    
    
    func panGesture(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: view)
        let velocity = recognizer.velocity(in: view)
//        let point = recognizer.location(in: view)
        
        if recognizer.state == .began {

        } else if recognizer.state == .changed {
            self.view.frame.origin.y = partialViewTopY + translation.y
            if self.view.frame.minY < (partialViewTopY + 5 ){
                openDrawer()

                
            } else {
                closeDrawer()

            }
            
        } else if recognizer.state == .ended {
            UIView.animate(withDuration: 0.3, animations: {
                if velocity.x > 0 { //opening drawer
                    self.view.frame.origin.y = 0
                    self.open = true
                    self.openDrawer()
                } else { //closing drawer
                    self.open = false
                    self.view.frame.origin.y = self.partialViewTopY
                    self.closeDrawer()
                    
                }
//                self.view.layoutIfNeeded()
            })
        }
        
        // fix this: put BottomDrawerVC above navbar
        if self.view.frame.minY < (self.navigationController?.navigationBar.frame.maxY)! {
            self.navigationController?.navigationBar.layer.zPosition = -1
        } else {
            self.navigationController?.navigationBar.layer.zPosition = 0
        }

        self.view.layoutIfNeeded()
        
        //                UIView.animate(withDuration: 0.3) { [weak self] in
        //                    self?.mainFullVC.view.alpha = 0
        //                    self?.smallDrawerView.alpha = 1
        //
        ////                    self?.mainFullVC.view.removeFromSuperview()
        ////                    self?.view.addSubview((self?.smallDrawerView)!)
        //                }
        
        //                UIView.animate(withDuration: 0.3) { [weak self] in
        //                    self?.smallDrawerView.alpha = 0
        ////                    self?.smallDrawerView.removeFromSuperview()
        ////                    self?.view.addSubview((self?.mainFullVC.view)!)
        //                    self?.mainFullVC.view.alpha = 1
        //                }
        
//        let translation = recognizer.translation(in: self.view)
//        let y = self.view.frame.minY
//        self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
//        
//        recognizer.setTranslation(CGPoint.zero, in: self.view)
//
//        if translation.y < partialViewTopY {
//            UIView.animate(withDuration: 0.3) { [weak self] in
//                self?.smallDrawerView.removeFromSuperview()
//                self?.view.addSubview((self?.mainFullVC.view)!)
//            }
//        }
//        if translation.y >= partialViewTopY {
//            UIView.animate(withDuration: 0.3) { [weak self] in
//                self?.mainFullVC.view.removeFromSuperview()
//                self?.view.addSubview((self?.smallDrawerView)!)
//            }
//        }

        
        
    }
    
    func openDrawer(){
        joinButt.isHidden = true
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.mainFullVC.view.alpha = 1
            self?.smallDrawerView.alpha = 0
            }, completion: { (finished: Bool) in
                self.smallDrawerView.isHidden = true
                self.mainFullVC.view.isHidden = false
                self.mainFullVC.view.isUserInteractionEnabled = true

        })
        
    }
    
    func closeDrawer(){
//        joinButt.isHidden = false
        UIView.animate(withDuration: 0.3, animations: { () in
            self.smallDrawerView.alpha = 1
            self.mainFullVC.view.alpha = 0
            }, completion: { (finished: Bool) in
                self.smallDrawerView.isHidden = false
                self.mainFullVC.view.isHidden = true
                self.mainFullVC.view.isUserInteractionEnabled = false

        })
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            print("the view that was tapped was recognized as a button")
            return false
        }
        print("not button")
        print(touch.view.debugDescription)
        return true

    }
    
    
//    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
//        if self.open {
//            mainFullVC.view.isUserInteractionEnabled = true
////            mainFullVC.tableView.isScrollEnabled = true
//        } else {
////            mainFullVC.tableView.isScrollEnabled = false
//            mainFullVC.view.isUserInteractionEnabled = false
//
//        }

//        let direction = gesture.velocity(in: view).y
//
//        let y = self.view.frame.minY
//        
//        if y == fullViewTopY {
//            mainFullVC.tableView.isScrollEnabled = true
//            
//        } else {
//            mainFullVC.tableView.isScrollEnabled = false
//        }
        
        
//        if (y == fullViewTopY && mainFullVC.tableView.contentOffset.y == 0 && direction > 0) || (y >= partialViewTopY) || (y > fullView) {
//            mainFullVC.tableView.isScrollEnabled = false
//        } else {

//            mainFullVC.tableView.isScrollEnabled = true
//            
//        } else {
//            mainFullVC.tableView.isScrollEnabled = false
//        }

//        
//        
////        if (y == fullViewTopY && mainFullVC.tableView.contentOffset.y == 0 && direction > 0) || (y >= partialViewTopY) || (y > fullView) {
////            mainFullVC.tableView.isScrollEnabled = false
////        } else {
////            mainFullVC.tableView.isScrollEnabled = true
////        }
//        return false
//    }


}
