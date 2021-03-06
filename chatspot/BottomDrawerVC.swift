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
    var isOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mainFullVC.view)
        view.addSubview(smallDrawerView)
        
        smallDrawerView.translatesAutoresizingMaskIntoConstraints = false
        let leadingConstraint = NSLayoutConstraint(item: smallDrawerView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: smallDrawerView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
        
        view.addConstraints([leadingConstraint, trailingConstraint])


        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        self.smallDrawerView.addGestureRecognizer(tapGesture)
        
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.tabBar.isUserInteractionEnabled = false

        UIView.animate(withDuration: 0.3) { () in
            
            // set up initial short height for partial view
            self.view.frame.origin.y = self.partialViewTopY
        }
        self.mainFullVC.view.alpha = 0
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        self.tabBarController?.tabBar.isUserInteractionEnabled = true
//        
//        UIView.animate(withDuration: 0.3, animations: { () in
//            
//            self.view.frame.origin.y = self.view.frame.maxY
//            
//            }, completion: { (finished: Bool) in
//                self.mainFullVC.view.removeFromSuperview()
//                self.smallDrawerView.removeFromSuperview()
//                self.removeChildVC()
//            })
//    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
        self.mainFullVC.view.removeFromSuperview()
        self.smallDrawerView.removeFromSuperview()
        self.removeChildVC()
    }
    
    func removeChildVC(){
        for childVC in self.childViewControllers {
            childVC.willMove(toParentViewController: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParentViewController()
            print("removing children")
        }
    }
    
    func updateJoinButton(){
        self.smallDrawerView.updateJoinButtonView()
    }
    
    func openDrawer(){
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.frame.origin.y = 0
            self?.mainFullVC.view.alpha = 1
            self?.smallDrawerView.alpha = 0
            self?.view.layoutIfNeeded()
            }, completion: { (finished: Bool) in
                self.isOpen = true
                self.mainFullVC.view.isUserInteractionEnabled = true
        })
        
    }
    
    func closeDrawer(completion: (() -> Void)?){
        UIView.animate(withDuration: 0.3, animations: { [weak self] () in
            self?.view.frame.origin.y = (self?.partialViewTopY)!
            self?.smallDrawerView.alpha = 1
            self?.mainFullVC.view.alpha = 0
            self?.view.layoutIfNeeded()
            
            }, completion: { (finished: Bool) in
                self.isOpen = false
                self.mainFullVC.view.isUserInteractionEnabled = false
        })
    }
    
//MARK: ============ Gesture Recognizer Methods ============

    func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        let velocity = recognizer.velocity(in: view)
        
        if recognizer.state == .began {

        } else if recognizer.state == .changed {
            var currentDrawerHeight: CGFloat!
            let fullScreenHeight = UIScreen.main.bounds.height

            if isOpen {
                currentDrawerHeight = 0 + translation.y
            } else {
                currentDrawerHeight = partialViewTopY + translation.y
            }
            print("translation.y: \(translation.y)")
            print("currentDrawerHeight: \(currentDrawerHeight!)")
            print("")
            self.view.frame.origin.y = currentDrawerHeight
            
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.mainFullVC.view.alpha = 1 - (currentDrawerHeight/fullScreenHeight)
                self?.smallDrawerView.alpha = currentDrawerHeight/fullScreenHeight
            })
            
        } else if recognizer.state == .ended {
            if velocity.y < 0 { //opening drawer

                self.openDrawer()
//                } //else if !isOpen && velocity.y > 0 { // if drawer is closed and velocity is pulling downwards
//                    self.dismiss(animated: true, completion: nil)
//                    (self.parent as! AroundMeVC).removeChildVC()
//                    return
            } else { //closing drawer
                self.closeDrawer(completion: nil)
            }
        }
        
        // if the drawer is over the navbar
        if self.view.frame.origin.y < (self.navigationController?.navigationBar.frame.maxY)! {
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
        } else {
            self.navigationController?.navigationBar.isUserInteractionEnabled = true

        }
        self.view.layoutIfNeeded()
    }
    
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        if !isOpen {
            openDrawer()
        }
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            print("the view that was tapped was recognized as a button")
            return false
        }
//        TODO: fix bug that lets you drag the chatroomdetail view up and expose the map
//        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
//            //            let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
//            let direction = panGesture.velocity(in: view).y
//            if (mainFullVC.tableView.contentOffset.y >= (mainFullVC.tableView.contentSize.height - mainFullVC.tableView.frame.size.height)) && direction < 0 {
//                return false
//            }
//        }
        print("In shouldReceive touch")
        return true

    }
    
//    when drawer is open, drawer pangesture should be off unless user is at top of table and scrolling up
//    when drawer is closed, tableviewscrolling should be off, and drawer pangesture should be on
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
//            let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
            let direction = panGesture.velocity(in: view).y
            
            if self.isOpen {
                // if you're at the top of the tableview content and you're still scrolling up
                print("mainFullVC.tableView.contentOffset.y: \(mainFullVC.tableView.contentOffset.y)")
                if (mainFullVC.tableView.contentOffset.y == 0 && direction > 0){
                    mainFullVC.tableView.isScrollEnabled = false
                } else {
                    print("TABLEVIEW SCROLL IS ENABLED. mainFullVC.tableView.contentOffset.y: \(mainFullVC.tableView.contentOffset.y)")

                    mainFullVC.tableView.isScrollEnabled = true
                }
                // need to check for scrolling down and bottom of tableview
            } else {
                mainFullVC.tableView.isScrollEnabled = false
            }
            
        }
        
        return false
        
    }
    
}
