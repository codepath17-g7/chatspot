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
    var widthConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.setUpTitle(title: "Around Me")
        self.aroundMeView.delegate = self
        setupSearchBar()
    }

    func setupSearchBar(){
        // Background view.
        navView = UIView()
        navView.backgroundColor = UIColor.ChatSpotColors.LighterGray
        navView.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.titleView = navView
        navView.superview!.addConstraint(NSLayoutConstraint(item: navView, attribute: .top, relatedBy: .equal, toItem: navView.superview!, attribute: .top, multiplier: 1, constant: 0))
        navView.addConstraint(NSLayoutConstraint(item: navView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: UIScreen.main.bounds.width))
        navView.addConstraint(NSLayoutConstraint(item: navView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: navigationController!.navigationBar.bounds.height))
        
        // Search button.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(open))
        
        // Search bar.
        searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        navView.addSubview(searchBar)
        
        navView.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .centerY, relatedBy: .equal, toItem: navView, attribute: .centerY, multiplier: 1, constant: 0))
        leftConstraint = NSLayoutConstraint(item: searchBar, attribute: .left, relatedBy: .equal, toItem: navigationItem.titleView, attribute: .leftMargin, multiplier: 1, constant: 0)
        leftConstraint.priority = UILayoutPriorityDefaultLow // Starts out as low priority so it has no effect.
        navView.addConstraint(leftConstraint)
        
        navView.addConstraint(NSLayoutConstraint(item: navigationItem.titleView!, attribute: .right, relatedBy: .equal, toItem: searchBar, attribute: .right, multiplier: 1, constant: 56))
        widthConstraint = NSLayoutConstraint(item: searchBar, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 10)
        widthConstraint.priority = UILayoutPriorityDefaultHigh  // Starts out as high priority so it does have effect.
        navView.addConstraint(widthConstraint)
        
        // Remove search bar border.
        searchBar.layer.borderColor = UIColor.ChatSpotColors.LighterGray.cgColor
        searchBar.layer.borderWidth = 1
        
        // Match background color.
        searchBar.barTintColor = UIColor.ChatSpotColors.LighterGray
        
        // Search bar starts invisible.
        searchBar.alpha = 0
    }
    
    func open() {
        
        let isClosing = leftConstraint.priority == UILayoutPriorityDefaultHigh
        
        if isClosing {
            leftConstraint.priority = UILayoutPriorityDefaultLow
            widthConstraint.priority = UILayoutPriorityDefaultHigh
//            navigationItem.setUpTitle(title: "Around Me")
//            navigationItem.leftBarButtonItem?.customView?.alpha = 0

        } else {
            leftConstraint.priority = UILayoutPriorityDefaultHigh
            widthConstraint.priority = UILayoutPriorityDefaultLow
        }
        
        // Animate change to visible.
        UIView.animate(withDuration: 2.0, animations: {
            // Switch the priorities to make search bar expand.
            self.searchBar.alpha = isClosing ? 0 : 1
//            self.navigationItem.leftBarButtonItem?.customView?.alpha = isClosing ? 1 : 0
            self.searchBar.layoutIfNeeded()
//            if !isClosing {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                    self.navigationItem.leftBarButtonItem = nil
//                    UIView.animate(withDuration: 1.0, animations: {
//                        self.searchBar.layoutIfNeeded()
//                    })
//                }
//            }
        },  completion: { (finished: Bool) in

        })
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //        let searchView = SearchView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: navigationController!.navigationBar.bounds.height))
//        
//        navigationItem.titleView = searchView
//        
//        
//        searchView.translatesAutoresizingMaskIntoConstraints = false
//        
//        searchViewLeadingConstraint = NSLayoutConstraint(item: searchView, attribute: .leading, relatedBy: .equal, toItem: navigationItem.titleView, attribute: .leading, multiplier: 1, constant: 0)
//        
//        
        
        
//        leftConstraint = NSLayoutConstraint(item: searchBar, attribute: .Left, relatedBy: .Equal, toItem: navigationItem.titleView, attribute: .LeftMargin, multiplier: 1, constant: 0)
//                leftConstraint.priority = UILayoutPriorityDefaultLow // Starts out as low priority so it has no effect.
//                navView.addConstraint(leftConstraint)
//        
//                navView.addConstraint(NSLayoutConstraint(item: navigationItem.titleView!, attribute: .right, relatedBy: .Equal, toItem: searchBar, attribute: .right, multiplier: 1, constant: 45))
//                widthConstraint = NSLayoutConstraint(item: searchBar, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: 10)
//                widthConstraint.priority = UILayoutPriorityDefaultHigh  // Starts out as high priority so it does have effect.
//                navView.addConstraint(widthConstraint)
//        
//        
//        let leadingConstraint = NSLayoutConstraint(item: smallDrawerView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
//        let trailingConstraint = NSLayoutConstraint(item: smallDrawerView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
//        
//        view.addConstraints([leadingConstraint, trailingConstraint])

        
        
        
        
        
        
        
//        setupSearchBar()
        
        // searchbar background view
//        searchBarView = UIView()
//        searchBarView.backgroundColor = UIColor.ChatSpotColors.LighterGray
//        searchBarView.translatesAutoresizingMaskIntoConstraints = false
//        navigationItem.titleView = searchBarView
//        
//        // searchbar
//        searchBar = UISearchBar(frame: CGRect(x: <#T##CGFloat#>, y: <#T##CGFloat#>, width: <#T##CGFloat#>, height: <#T##CGFloat#>))
//        searchBar.delegate = self
//        searchBar.searchBarStyle = UISearchBarStyle.minimal
//        
//        searchBarView.addSubview(searchBar)
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(openSearchBar))
//        
//    }
//    
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        
//    }
//    
//
//    func openSearchBar(){
//        
//    }
    
//    class ViewController : UIViewController, UISearchBarDelegate {
//        var searchBar = UISearchBar()
//        var searchBarButtonItem: UIBarButtonItem?
//        var logoImageView   : UIImageView!
    
//        override func viewDidLoad() {
//            super.viewDidLoad()
    
            // Can replace logoImageView for titleLabel of navbar

    
//        
//        @IBAction func searchButtonPressed(sender: AnyObject) {
//            showSearchBar()
//        }
//        
//        
//        func openSearchBar() {
//            searchBar.alpha = 0
//            navigationItem.titleView = searchBar
//            navigationItem.setLeftBarButtonItem(nil, animated: true)
//            UIView.animateWithDuration(0.5, animations: {
//                self.searchBar.alpha = 1
//            }, completion: { finished in
//                self.searchBar.becomeFirstResponder()
//            })
//        }
//        
//        func closeSearchBar() {
//            navigationItem.setLeftBarButtonItem(searchBarButtonItem, animated: true)
//            logoImageView.alpha = 0
//            UIView.animateWithDuration(0.3, animations: {
//                self.navigationItem.titleView = self.logoImageView
//                self.logoImageView.alpha = 1
//            }, completion: { finished in
//                
//            })
//        }
//        
//        
//        //MARK: UISearchBarDelegate
//        func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//            hideSearchBar()
//        }
    
    
    
// FIXME: needs work
//    func setupSearchBar(){
    
//        // Background view.
//        searchView = UIView()
//        searchView.backgroundColor = UIColor.ChatSpotColors.LighterGray
//        searchView.translatesAutoresizingMaskIntoConstraints = false
//        navigationItem.titleView = searchView
//        
//        searchView.superview!.addConstraint(NSLayoutConstraint(item: searchView, attribute: .top, relatedBy: .equal, toItem: searchView.superview!, attribute: .top, multiplier: 1, constant: 0))
//        searchView.addConstraint(NSLayoutConstraint(item: searchView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: UIScreen.main.bounds.width))
//        searchView.addConstraint(NSLayoutConstraint(item: searchView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: navigationController!.navigationBar.bounds.height))
//        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(openSearchBar))
//        
//        // Search bar.
//        searchBar = UISearchBar()
//        searchBar.translatesAutoresizingMaskIntoConstraints = false
//        searchView.addSubview(searchBar)
        
//        navView.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .CenterY, relatedBy: .Equal, toItem: navView, attribute: .CenterY, multiplier: 1, constant: 0))
//        leftConstraint = NSLayoutConstraint(item: searchBar, attribute: .Left, relatedBy: .Equal, toItem: navigationItem.titleView, attribute: .LeftMargin, multiplier: 1, constant: 0)
//        leftConstraint.priority = UILayoutPriorityDefaultLow // Starts out as low priority so it has no effect.
//        navView.addConstraint(leftConstraint)
//        
//        navView.addConstraint(NSLayoutConstraint(item: navigationItem.titleView!, attribute: .Right, relatedBy: .Equal, toItem: searchBar, attribute: .Right, multiplier: 1, constant: 45))
//        widthConstraint = NSLayoutConstraint(item: searchBar, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: 10)
//        widthConstraint.priority = UILayoutPriorityDefaultHigh  // Starts out as high priority so it does have effect.
//        navView.addConstraint(widthConstraint)
//        
        
//        searchView.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .centerY, relatedBy: .equal, toItem: searchView, attribute: .centerY, multiplier: 1, constant: 0))
//        
//        leftConstraint = NSLayoutConstraint(item: searchBar, attribute: .left, relatedBy: .equal, toItem: navigationItem.titleView, attribute: .leftMargin, multiplier: 1, constant: 0)
//        
//        leftConstraint.priority = UILayoutPriorityDefaultLow // Starts out as low priority so it has no effect.
//        searchView.addConstraint(leftConstraint)
//        
//        searchView.addConstraint(NSLayoutConstraint(item: navigationItem.titleView!, attribute: .right, relatedBy: .equal, toItem: searchBar, attribute: .right, multiplier: 1, constant: 70))
//        widthConstraint = NSLayoutConstraint(item: searchBar, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 10)
//        widthConstraint.priority = UILayoutPriorityDefaultHigh  // Starts out as high priority so it does have effect.
//        searchView.addConstraint(widthConstraint)
//        
//        // Remove search bar border.
//        searchBar.layer.borderColor = UIColor.ChatSpotColors.LighterGray.cgColor
//        searchBar.layer.borderWidth = 1
//        
//        // Match background color.
//        searchBar.barTintColor = UIColor.ChatSpotColors.LighterGray
//        
//        // Search bar starts invisible.
//        searchBar.alpha = 0
//    }
//    
//    func openSearchBar() {
//        
//        let isClosing = leftConstraint.priority == UILayoutPriorityDefaultHigh
//        
//        // Switch the priorities to make search bar expand.
//        if isClosing {
//            leftConstraint.priority = UILayoutPriorityDefaultLow
//            widthConstraint.priority = UILayoutPriorityDefaultHigh
//            navigationItem.setUpTitle(title: "Around Me")
//        } else {
//            leftConstraint.priority = UILayoutPriorityDefaultHigh
//            widthConstraint.priority = UILayoutPriorityDefaultLow
//             navigationItem.leftBarButtonItem = nil
//        }
//        
//        // Animate change to visible.
//        UIView.animate(withDuration: 2, animations: {
//            self.searchBar.alpha = isClosing ? 0 : 1
//            self.searchBar.layoutIfNeeded()
////            if let titleItem = self.navigationItem.leftBarButtonItem {
////                self.navigationItem.leftBarButtonItem?.customView?.alpha = isClosing ? 1 : 0
////            }
//        })
//    }

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

