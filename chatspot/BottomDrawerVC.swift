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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isUserInteractionEnabled = true
        
        self.view.addSubview(smallDrawerView)

        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture))
        gesture.delegate = self
        
        view.addGestureRecognizer(gesture)
        
        
        
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
            self?.tabBarController?.tabBar.layer.zPosition = -1
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
        self.tabBarController?.tabBar.layer.zPosition = 0
        self.tabBarController?.tabBar.isUserInteractionEnabled = true


//        UIView.animate(withDuration: 0.3) { [weak self] in
//            self?.tabBarController?.tabBar.layer.zPosition = 0
//        }
    }
    
    

    
    
    func panGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        let y = self.view.frame.minY
        self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
        if translation.y < yComponent {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.smallDrawerView.removeFromSuperview()
                self?.view.addSubview((self?.mainFullVC.view)!)
            }
        }
        if translation.y >= yComponent {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.mainFullVC.view.removeFromSuperview()
                self?.view.addSubview((self?.smallDrawerView)!)
            }
        }
        if translation.y < (self.navigationController?.navigationBar.frame.maxY)! {
            self.navigationController?.navigationBar.layer.zPosition = -1
        } else {
            self.navigationController?.navigationBar.layer.zPosition = 0
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self.view)
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        return true
    }
    
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: view).y

        let y = self.view.frame.minY
        
        if y == fullView {
            mainFullVC.tableView.isScrollEnabled = true
            
        } else {
            mainFullVC.tableView.isScrollEnabled = false
        }
        
        
//        if (y == fullView && mainFullVC.tableView.contentOffset.y == 0 && direction > 0) || (y >= yComponent) || (y > fullView) {
//            mainFullVC.tableView.isScrollEnabled = false
//        } else {
//            mainFullVC.tableView.isScrollEnabled = true
//        }
        return false
    }


}
