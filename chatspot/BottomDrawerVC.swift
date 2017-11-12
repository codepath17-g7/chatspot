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
        
        
//        view.addSubview(mainFullVC.view)
//        view.insertSubview(smallDrawerView, at: 0)
//        view.addSubview(smallDrawerView)
        
//        smallDrawerView.bringSubview(toFront: smallDrawerView.joinButton)

        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.3, animations: { () in
            
            self.view.frame.origin.y = UIScreen.main.bounds.height
            
            }, completion: { (finished: Bool) in
                self.mainFullVC.view.removeFromSuperview()
                self.smallDrawerView.removeFromSuperview()
                self.removeChildVC()
            })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
    }
    
    func removeChildVC(){
        for childVC in self.childViewControllers {
            childVC.willMove(toParentViewController: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParentViewController()
            print("removing children")
        }
    }

    
    
    func panGesture(recognizer: UIPanGestureRecognizer) {
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            print("the view that was tapped was recognized as a button")
            return false
        }
        print("not button")
        print(touch.view.debugDescription)
        return true

    }
//    
//    when drawer is open
//        when user has scrolled to the top of the tableview and tries to scroll up (pos or neg velocity?), turn tableviewscrolling off, turn pan gesture for drawer on
//        if user tries to scroll down, scroll tableview, disable drawer pangesture
//    
//        drawer pangesture should be off unless user is at top of table and scrolling up
//    when drawer is closed
//        tableviewscrolling should be off, and drawer pangesture should be on
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: view).y

        if self.isOpen {
            // if you're at the top of the tableview content and you're still scrolling up,
            if (mainFullVC.tableView.contentOffset.y == 0 && direction > 0){
                mainFullVC.tableView.isScrollEnabled = false
            } else {
                mainFullVC.tableView.isScrollEnabled = true
            }
            
//            mainFullVC.view.isUserInteractionEnabled = true
//            mainFullVC.tableView.isScrollEnabled = true
        } else {
            mainFullVC.tableView.isScrollEnabled = false

//            mainFullVC.tableView.isScrollEnabled = false
//            mainFullVC.view.isUserInteractionEnabled = false

        }
        
        return false
    }
    
}


//        let y = self.view.frame.minY
//        
//        if y == fullViewTopY {
//            mainFullVC.tableView.isScrollEnabled = true
//            
//        } else {
//            mainFullVC.tableView.isScrollEnabled = false
//        }
//        
//        
//        if (y == fullViewTopY && mainFullVC.tableView.contentOffset.y == 0 && direction > 0) || (y >= partialViewTopY) || (y > fullView) {
//            mainFullVC.tableView.isScrollEnabled = false
//        } else {
//
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

    //            leftMarginConstraint.constant = originalLeftMargin + translation.x
    //            if velocity.x > 0 { //opening menu
    //                self.leftMarginConstraint.constant = self.view.frame.size.width - self.view.frame.size.width/2
    //            } else { //closing menu
    //                self.leftMarginConstraint.constant = 0
    //            }
    //            if self.view.frame.origin.y < (partialViewTopY + 5 ){
    //                openDrawer()
    
    
    //            } else {
    //                closeDrawer()
    
    //            }
    
    //            if velocity.x > 0 { //opening menu
    //                self.leftMarginConstraint.constant = self.view.frame.size.width - self.view.frame.size.width/2
    //            } else { //closing menu
    //                self.leftMarginConstraint.constant = 0
    //            }

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

//        var tabBarFrame = self.tabBarController?.tabBar.frame
//        tabBarFrame?.origin.y = self.view.frame.size.height - (tabBarFrame?.size.height)!
//        self.tabBarController?.tabBar.frame = tabBarFrame!
//        var tabBarFrame = self.tabBarController?.tabBar.frame
//        tabBarFrame?.origin.y = self.view.frame.size.height + (tabBarFrame?.size.height)!
//        self.tabBarController?.tabBar.frame = tabBarFrame!
//        self.tabBarController?.tabBar.isEnabled = false



//                self.smallDrawerView.isHidden = false
//                self.mainFullVC.view.isHidden = true
//                self.present(self.mainFullVC, animated: false, completion: nil)
//                self.parent?.present(self.mainFullVC, animated: false, completion: nil)
//                self.smallDrawerView.isHidden = true
//                self.mainFullVC.view.isHidden = false
