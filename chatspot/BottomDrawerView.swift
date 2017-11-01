////
////  BottomDrawerView.swift
////  chatspot
////
////  Created by Eden on 11/1/17.
////  Copyright © 2017 g7. All rights reserved.
////
//
//import UIKit
//
//class BottomDrawerView: UIView {
//        var mainFullVC: UIView!
//        var smallDrawerView: ChatroomCardView!
//        
//        let partialViewTopY = UIScreen.main.bounds.height - 139
//        let fullViewTopY = UIScreen.main.bounds.minY
//        var open = false
//    
//    init(frame: CGRect, image: UIImage) {
//        
//            self.isUserInteractionEnabled = true
//            
//            self.addSubview(smallDrawerView)
//            self.addSubview(mainFullVC)
//            self.mainFullVC.isHidden = true
//            
//            let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture))
//            gesture.delegate = self
//            
//            self.addGestureRecognizer(gesture)
//            
//        }
//        
//        override func viewDidAppear(_ animated: Bool) {
//            super.viewDidAppear(animated)
//            
//            //        var tabBarFrame = self.tabBarController?.tabBar.frame
//            //        tabBarFrame?.origin.y = self.view.frame.size.height + (tabBarFrame?.size.height)!
//            //        self.tabBarController?.tabBar.frame = tabBarFrame!
//            //        self.tabBarController?.tabBar.isEnabled = false
//            // do this only for map pin click
//            UIView.animate(withDuration: 0.3) { [weak self] in
//                self?.tabBarController?.tabBar.layer.zPosition = (self?.view.layer.zPosition)! - 50
//                self?.tabBarController?.tabBar.isHidden = true
//                self?.parent?.tabBarController?.tabBar.isHidden = true
//                self?.tabBarController?.tabBar.isUserInteractionEnabled = false
//                
//                // set up initial short height for partial view
//                let frame = self?.view.frame
//                self?.view.frame = CGRect(x: 0, y: (self?.partialViewTopY)!, width: frame!.width, height: frame!.height)
//            }
//        }
//        
//        override func viewWillDisappear(_ animated: Bool) {
//            //        var tabBarFrame = self.tabBarController?.tabBar.frame
//            //        tabBarFrame?.origin.y = self.view.frame.size.height - (tabBarFrame?.size.height)!
//            //        self.tabBarController?.tabBar.frame = tabBarFrame!
//            
//            
//            UIView.animate(withDuration: 0.3, animations: { [weak self] in
//                print("animation called!!!!!")
//                let frame = self?.view.frame
//                self?.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: frame!.width, height: frame!.height)
//                }, completion: { (finished: Bool) in
//                    self.mainFullVC.view.removeFromSuperview()
//                    self.smallDrawerView.removeFromSuperview()
//                    
//            })
//        }
//        
//        override func viewDidDisappear(_ animated: Bool) {
//            self.tabBarController?.tabBar.layer.zPosition = 0
//            self.tabBarController?.tabBar.isHidden = false
//            self.parent?.tabBarController?.tabBar.isHidden = false
//            
//            self.tabBarController?.tabBar.isUserInteractionEnabled = true
//            
//            
//            //        UIView.animate(withDuration: 0.3) { [weak self] in
//            //            self?.tabBarController?.tabBar.layer.zPosition = 0
//            //        }
//        }
//        
//        
//        
//        
//        
//        func panGesture(recognizer: UIPanGestureRecognizer) {
//            
//            let translation = recognizer.translation(in: view)
//            let velocity = recognizer.velocity(in: view)
//            //        let point = recognizer.location(in: view)
//            
//            if recognizer.state == .began {
//                
//            } else if recognizer.state == .changed {
//                self.view.frame = CGRect(x: 0, y: partialViewTopY + translation.y, width: view.frame.width, height: view.frame.height)
//                
//                if self.view.frame.minY < (partialViewTopY + 5 ){
//                    openDrawer()
//                    
//                    
//                } else {
//                    closeDrawer()
//                    
//                }
//                
//            } else if recognizer.state == .ended {
//                UIView.animate(withDuration: 0.3, animations: {
//                    if velocity.x > 0 { //opening drawer
//                        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
//                        self.open = true
//                        self.openDrawer()
//                    } else { //closing drawer
//                        self.open = false
//                        self.view.frame = CGRect(x: 0, y: self.partialViewTopY, width: self.view.frame.width, height: self.view.frame.height)
//                        self.closeDrawer()
//                        
//                    }
//                    //                self.view.layoutIfNeeded()
//                })
//            }
//            
//            // fix this: put BottomDrawerVC above navbar
//            if self.view.frame.minY < (self.navigationController?.navigationBar.frame.maxY)! {
//                self.navigationController?.navigationBar.layer.zPosition = -1
//            } else {
//                self.navigationController?.navigationBar.layer.zPosition = 0
//            }
//            
//            self.view.layoutIfNeeded()
//            
//            //                UIView.animate(withDuration: 0.3) { [weak self] in
//            //                    self?.mainFullVC.view.alpha = 0
//            //                    self?.smallDrawerView.alpha = 1
//            //
//            ////                    self?.mainFullVC.view.removeFromSuperview()
//            ////                    self?.view.addSubview((self?.smallDrawerView)!)
//            //                }
//            
//            //                UIView.animate(withDuration: 0.3) { [weak self] in
//            //                    self?.smallDrawerView.alpha = 0
//            ////                    self?.smallDrawerView.removeFromSuperview()
//            ////                    self?.view.addSubview((self?.mainFullVC.view)!)
//            //                    self?.mainFullVC.view.alpha = 1
//            //                }
//            
//            //        let translation = recognizer.translation(in: self.view)
//            //        let y = self.view.frame.minY
//            //        self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
//            //
//            //        recognizer.setTranslation(CGPoint.zero, in: self.view)
//            //
//            //        if translation.y < partialViewTopY {
//            //            UIView.animate(withDuration: 0.3) { [weak self] in
//            //                self?.smallDrawerView.removeFromSuperview()
//            //                self?.view.addSubview((self?.mainFullVC.view)!)
//            //            }
//            //        }
//            //        if translation.y >= partialViewTopY {
//            //            UIView.animate(withDuration: 0.3) { [weak self] in
//            //                self?.mainFullVC.view.removeFromSuperview()
//            //                self?.view.addSubview((self?.smallDrawerView)!)
//            //            }
//            //        }
//            
//            
//            
//        }
//        
//        func openDrawer(){
//            UIView.animate(withDuration: 0.3, animations: { [weak self] in
//                self?.mainFullVC.view.alpha = 1
//                self?.smallDrawerView.alpha = 0
//                }, completion: { (finished: Bool) in
//                    self.smallDrawerView.isHidden = true
//                    self.mainFullVC.view.isHidden = false
//                    self.mainFullVC.view.isUserInteractionEnabled = true
//                    
//            })
//            
//            
//        }
//        
//        func closeDrawer(){
//            UIView.animate(withDuration: 0.3, animations: { [weak self] in
//                self?.smallDrawerView.alpha = 1
//                self?.mainFullVC.view.alpha = 0
//                }, completion: { (finished: Bool) in
//                    self.smallDrawerView.isHidden = false
//                    self.mainFullVC.view.isHidden = true
//                    self.mainFullVC.view.isUserInteractionEnabled = false
//                    
//            })
//        }
//        
//        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//            if touch.view is UIButton {
//                print("the view that was tapped was recognized as a button")
//                return false
//            }
//            print("not button")
//            return true
//            
//        }
//
//
//}
