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
    
    var searchBar: UISearchBar!
    var searchView: UIView!
    var leftConstraint: NSLayoutConstraint!
    var widthConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setUpTitle(title: "Around Me")
        self.aroundMeView.delegate = self
        setupSearchBar()
    }
    
    
// FIXME: needs work
    func setupSearchBar(){
        
        // Background view.
        searchView = UIView()
        searchView.backgroundColor = UIColor.ChatSpotColors.LighterGray
        searchView.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.titleView = searchView
        searchView.superview!.addConstraint(NSLayoutConstraint(item: searchView, attribute: .top, relatedBy: .equal, toItem: searchView.superview!, attribute: .top, multiplier: 1, constant: 0))
        searchView.addConstraint(NSLayoutConstraint(item: searchView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: UIScreen.main.bounds.width))
        searchView.addConstraint(NSLayoutConstraint(item: searchView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: navigationController!.navigationBar.bounds.height))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(openSearchBar))
        
        // Search bar.
        searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchView.addSubview(searchBar)
        
        searchView.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .centerY, relatedBy: .equal, toItem: searchView, attribute: .centerY, multiplier: 1, constant: 0))
        leftConstraint = NSLayoutConstraint(item: searchBar, attribute: .left, relatedBy: .equal, toItem: navigationItem.titleView, attribute: .leftMargin, multiplier: 1, constant: 0)
        leftConstraint.priority = UILayoutPriorityDefaultLow // Starts out as low priority so it has no effect.
        searchView.addConstraint(leftConstraint)
        
        searchView.addConstraint(NSLayoutConstraint(item: navigationItem.titleView!, attribute: .right, relatedBy: .equal, toItem: searchBar, attribute: .right, multiplier: 1, constant: 45))
        widthConstraint = NSLayoutConstraint(item: searchBar, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 10)
        widthConstraint.priority = UILayoutPriorityDefaultHigh  // Starts out as high priority so it does have effect.
        searchView.addConstraint(widthConstraint)
        
        // Remove search bar border.
        searchBar.layer.borderColor = UIColor.ChatSpotColors.LighterGray.cgColor
        searchBar.layer.borderWidth = 1
        
        // Match background color.
        searchBar.barTintColor = UIColor.ChatSpotColors.LighterGray
        
        // Search bar starts invisible.
        searchBar.alpha = 0
    }
    
    func openSearchBar() {
        
        let isClosing = leftConstraint.priority == UILayoutPriorityDefaultHigh
        
        // Switch the priorities to make search bar expand.
        if isClosing {
            leftConstraint.priority = UILayoutPriorityDefaultLow
            widthConstraint.priority = UILayoutPriorityDefaultHigh
//            navigationItem.setUpTitle(title: "Around Me")
        } else {
            leftConstraint.priority = UILayoutPriorityDefaultHigh
            widthConstraint.priority = UILayoutPriorityDefaultLow
             navigationItem.leftBarButtonItem = nil
        }
        
        // Animate change to visible.
        UIView.animate(withDuration: 2, animations: {
            self.searchBar.alpha = isClosing ? 0 : 1
            self.searchBar.layoutIfNeeded()
//            if let titleItem = self.navigationItem.leftBarButtonItem {
//                self.navigationItem.leftBarButtonItem?.customView?.alpha = isClosing ? 1 : 0
//            }
        })
    }

}

extension AroundMeVC: AroundMeViewDelegate {
    
    func hideDrawer() {
        // slide down, remove child
        if let childVC = self.childViewControllers.last as? BottomDrawerVC {
            UIView.animate(withDuration: 0.3, animations: {
                childVC.view.frame.origin.y = self.view.frame.maxY

            }, completion: { (finished: Bool) in
                self.removeChildVC()
            })
        }
    }
    
    func removeChildVC(){
        
        for childVC in self.childViewControllers {
            childVC.willMove(toParentViewController: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParentViewController()
            
            print("removing last childvc")
        }
    }
    
    
    func mapPinButtonClicked(roomGuid: String) {
        removeChildVC()
        
        if let chatRoom = ChatSpotClient.chatrooms[roomGuid] {
            
            let bottomDrawerVC = BottomDrawerVC()
            
            // create small view
            let chatroomCardView = ChatroomCardView(frame: CGRect(x: 0, y: 0, width: 375, height: 139))
            chatroomCardView.chatRoom = chatRoom

            
            
            
//            let verticalConstraint = NSLayoutConstraint(item: chatroomCardView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: bottomDrawerVC.view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
//            let widthConstraint = NSLayoutConstraint(item: chatroomCardView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100)
//            let heightConstraint = NSLayoutConstraint(item: chatroomCardView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100)
            
            // create fullsize view
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let chatroomDetailVC = storyboard.instantiateViewController(withIdentifier: "ChatRoomDetailVC") as! ChatRoomDetailVC
            chatroomDetailVC.chatroom = chatRoom
            
            bottomDrawerVC.mainFullVC = chatroomDetailVC
            bottomDrawerVC.smallDrawerView = chatroomCardView
            bottomDrawerVC.view.addSubview(bottomDrawerVC.mainFullVC.view)
            bottomDrawerVC.view.addSubview(bottomDrawerVC.smallDrawerView)
            bottomDrawerVC.addChildViewController(chatroomDetailVC)
            
            chatroomCardView.translatesAutoresizingMaskIntoConstraints = false
            let leadingConstraint = NSLayoutConstraint(item: chatroomCardView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: bottomDrawerVC.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
            let trailingConstraint = NSLayoutConstraint(item: chatroomCardView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: bottomDrawerVC.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
//            let bottomConstraint = NSLayoutConstraint(item: chatroomCardView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: bottomDrawerVC.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
//            let heightConstraint = NSLayoutConstraint(item: chatroomCardView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 139)
            bottomDrawerVC.view.addConstraints([leadingConstraint, trailingConstraint])

            
            // Adjust bottomDrawerVC frame and initial position (below the screen)
            bottomDrawerVC.view.frame.origin.y = self.view.frame.maxY

            
            // add bottomDrawerVC as a child view
            addChildViewController(bottomDrawerVC)
            view.addSubview(bottomDrawerVC.view)
            UIApplication.shared.keyWindow!.insertSubview(bottomDrawerVC.view, aboveSubview: tabBarController!.tabBar)

        }
    }
}

