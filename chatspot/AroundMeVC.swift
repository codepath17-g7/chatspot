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
        
        addBottomSheetView()
        setupSearchBar()
        

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    
    func addBottomSheetView() {
        // 1- Init bottomSheetVC
        let bottomSheetVC = ChatRoomDetailVC()
        
        // 2- Add bottomSheetVC as a child view
        self.addChildViewController(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParentViewController: self)
        
        // 3- Adjust bottomSheet frame and initial position.
        let height = view.frame.height
        let width  = view.frame.width
        bottomSheetVC.view.frame = CGRectMake(0, self.view.frame.maxY, width, height)
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(open))
        
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
    
    func open() {
        
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
