//
//  AroundMeVC.swift
//  chatspot
//
//  Created by Eden on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class AroundMeVC: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var aroundMeView: AroundMeView!
    
    var navView: UIView!
    var searchBar: UISearchBar!
    var leftConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setUpTitle(title: "Around Me")
        self.aroundMeView.delegate = self
//        setupSearchBar()
    }

    func setupSearchBar(){
        
        // Expandable area.
        let expandableView = ExpandableView()
        navigationItem.titleView = expandableView
        
        
        // Search button.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(toggle))
        
        
        expandableView.superview!.addConstraint(NSLayoutConstraint(item: expandableView, attribute: .right, relatedBy: .equal, toItem: expandableView.superview!, attribute: .right, multiplier: 1, constant: 60))

        
        // Search bar.
        searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        expandableView.addSubview(searchBar)
        leftConstraint = searchBar.leftAnchor.constraint(equalTo: expandableView.leftAnchor)
        leftConstraint.isActive = false
        searchBar.rightAnchor.constraint(equalTo: expandableView.rightAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: expandableView.topAnchor).isActive = true
        searchBar.bottomAnchor.constraint(equalTo: expandableView.bottomAnchor).isActive = true
        
        // Remove search bar border.
        searchBar.layer.borderColor = UIColor.ChatSpotColors.LighterGray.cgColor
        searchBar.layer.borderWidth = 1

        // Match background color.
        searchBar.barTintColor = UIColor.ChatSpotColors.LighterGray
    }
    
    
    
    @objc func toggle() {
        
        let isOpen = leftConstraint.isActive == true
        
        // Inactivating the left constraint closes the expandable header.
        if isOpen {
            leftConstraint.isActive = false
            navigationItem.setUpTitle(title: "Around Me")
            navigationItem.leftBarButtonItem?.customView?.alpha = 0
        } else {
            leftConstraint.isActive = true

        }
        // Animate change to visible.
        
        UIView.animate(withDuration: 1.5, animations: {
            self.navigationItem.titleView?.layoutIfNeeded()
            self.searchBar.layoutIfNeeded()
        })
        
        UIView.animate(withDuration: 1.5, animations: {
            self.navigationItem.titleView?.alpha = isOpen ? 0 : 1
            self.navigationItem.leftBarButtonItem?.customView?.alpha = isOpen ? 1 : 0
//            self.navigationItem.titleView?.layoutIfNeeded()
//            self.searchBar.layoutIfNeeded()
        },  completion: { (finished: Bool) in
            if !isOpen {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
                    self.navigationItem.leftBarButtonItem = nil
                    UIView.animate(withDuration: 1.5, animations: {
                        self.searchBar.layoutIfNeeded()
                    })
//                }
            }


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
        tabBarController?.tabBar.isUserInteractionEnabled = true
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
            
            // create fullsize view
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let chatroomDetailVC = storyboard.instantiateViewController(withIdentifier: "ChatRoomDetailVC") as! ChatRoomDetailVC
            chatroomDetailVC.chatroom = chatRoom
            
            bottomDrawerVC.mainFullVC = chatroomDetailVC
            bottomDrawerVC.smallDrawerView = chatroomCardView
            bottomDrawerVC.addChildViewController(chatroomDetailVC)

            // Adjust bottomDrawerVC frame and initial position (below the screen)
            bottomDrawerVC.view.frame.origin.y = self.view.frame.maxY

            
            // add bottomDrawerVC as a child view
            addChildViewController(bottomDrawerVC)
            view.addSubview(bottomDrawerVC.view)
            UIApplication.shared.keyWindow!.insertSubview(bottomDrawerVC.view, aboveSubview: tabBarController!.tabBar)

        }
    }
}

class ExpandableView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.ChatSpotColors.LighterGray
        translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
//        return CGSize(width: 300, height: 44)
    }
}

