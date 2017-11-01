//
//  BottomDrawerVC.swift
//  chatspot
//
//  Created by Eden on 10/31/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class BottomDrawerVC: UIViewController {
    var mainFullVC: ChatRoomDetailVC!
    var smallDrawerView: ChatroomCardView!

    let yComponent = UIScreen.main.bounds.height - 139
    let fullView = UIScreen.main.bounds.minY
    var open = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isUserInteractionEnabled = true
        
        self.view.addSubview(smallDrawerView)
        self.view.addSubview(mainFullVC.view)
        self.mainFullVC.view.isHidden = true
//        closeDrawer()

//        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture))
//        gesture.delegate = self
//        
//        view.addGestureRecognizer(gesture)
//        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        var tabBarFrame = self.tabBarController?.tabBar.frame
//        tabBarFrame?.origin.y = self.view.frame.size.height + (tabBarFrame?.size.height)!
//        self.tabBarController?.tabBar.frame = tabBarFrame!
//        self.tabBarController?.tabBar.isEnabled = false
        // do this only for map pin click
        UIView.animate(withDuration: 0.3) { [weak self] in
//            self?.tabBarController?.tabBar.layer.zPosition = (self?.view.layer.zPosition)! - 1
            self?.tabBarController?.tabBar.isHidden = true
            self?.tabBarController?.tabBar.isUserInteractionEnabled = false
            
            let frame = self?.view.frame
//            let yComponent = UIScreen.main.bounds.height - 139
            self?.view.frame = CGRect(x: 0, y: (self?.yComponent)!, width: frame!.width, height: frame!.height)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        var tabBarFrame = self.tabBarController?.tabBar.frame
//        tabBarFrame?.origin.y = self.view.frame.size.height - (tabBarFrame?.size.height)!
//        self.tabBarController?.tabBar.frame = tabBarFrame!

        
        UIView.animate(withDuration: 0.3) { [weak self] in
            print("animation called!!!!!")
            let frame = self?.view.frame
            let yComponent = UIScreen.main.bounds.height
            self?.view.frame = CGRect(x: 0, y: yComponent, width: frame!.width, height: frame!.height)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        self.tabBarController?.tabBar.layer.zPosition = 0
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isUserInteractionEnabled = true


//        UIView.animate(withDuration: 0.3) { [weak self] in
//            self?.tabBarController?.tabBar.layer.zPosition = 0
//        }
    }
    
    

    
    
    func panGesture(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: view)
        let velocity = recognizer.velocity(in: view)
        let point = recognizer.location(in: view)
        
        if recognizer.state == .began {

        } else if recognizer.state == .changed {
            self.view.frame = CGRect(x: 0, y: yComponent + translation.y, width: view.frame.width, height: view.frame.height)
            
            if self.view.frame.minY < yComponent {
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    self?.smallDrawerView.alpha = 0
                    self?.mainFullVC.view.alpha = 1
                    }, completion: { (finished: Bool) in
                        self.smallDrawerView.isHidden = true
                        self.mainFullVC.view.isHidden = false
                })
//                UIView.animate(withDuration: 0.3) { [weak self] in
//                    self?.smallDrawerView.alpha = 0
////                    self?.smallDrawerView.removeFromSuperview()
////                    self?.view.addSubview((self?.mainFullVC.view)!)
//                    self?.mainFullVC.view.alpha = 1
//                }
                
            } else {
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    self?.smallDrawerView.alpha = 1
                    self?.mainFullVC.view.alpha = 0
                    }, completion: { (finished: Bool) in
                        self.smallDrawerView.isHidden = false
                        self.mainFullVC.view.isHidden = true
                })
//                UIView.animate(withDuration: 0.3) { [weak self] in
//                    self?.mainFullVC.view.alpha = 0
//                    self?.smallDrawerView.alpha = 1
//
////                    self?.mainFullVC.view.removeFromSuperview()
////                    self?.view.addSubview((self?.smallDrawerView)!)
//                }
            }
            
        } else if recognizer.state == .ended {
            UIView.animate(withDuration: 0.3, animations: {
                if velocity.x > 0 { //opening drawer
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                    self.open = true
                } else { //closing drawer
                    self.open = false
                    self.view.frame = CGRect(x: 0, y: self.yComponent, width: self.view.frame.width, height: self.view.frame.height)
                    
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
        
        
        
//        let translation = recognizer.translation(in: self.view)
//        let y = self.view.frame.minY
//        self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
//        
//        recognizer.setTranslation(CGPoint.zero, in: self.view)
//
//        if translation.y < yComponent {
//            UIView.animate(withDuration: 0.3) { [weak self] in
//                self?.smallDrawerView.removeFromSuperview()
//                self?.view.addSubview((self?.mainFullVC.view)!)
//            }
//        }
//        if translation.y >= yComponent {
//            UIView.animate(withDuration: 0.3) { [weak self] in
//                self?.mainFullVC.view.removeFromSuperview()
//                self?.view.addSubview((self?.smallDrawerView)!)
//            }
//        }

        
        
    }
    
    func openDrawer(){
        mainFullVC.view.isUserInteractionEnabled = true
        
    }
    
    func closeDrawer(){
        mainFullVC.view.isUserInteractionEnabled = false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
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
//        if y == fullView {
//            mainFullVC.tableView.isScrollEnabled = true
//            
//        } else {
//            mainFullVC.tableView.isScrollEnabled = false
//        }
        
        
//        if (y == fullView && mainFullVC.tableView.contentOffset.y == 0 && direction > 0) || (y >= yComponent) || (y > fullView) {
//            mainFullVC.tableView.isScrollEnabled = false
//        } else {

//            mainFullVC.tableView.isScrollEnabled = true
//            
//        } else {
//            mainFullVC.tableView.isScrollEnabled = false
//        }

//        
//        
////        if (y == fullView && mainFullVC.tableView.contentOffset.y == 0 && direction > 0) || (y >= yComponent) || (y > fullView) {
////            mainFullVC.tableView.isScrollEnabled = false
////        } else {
////            mainFullVC.tableView.isScrollEnabled = true
////        }
//        return false
//    }


}
