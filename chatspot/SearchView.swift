//
//  SearchView.swift
//  chatspot
//
//  Created by Eden on 11/14/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class SearchView: UIView {
    
    @IBOutlet var contentView: UIView!

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchBarWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchBarLeadingConstraint: NSLayoutConstraint!

    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
    }
    
    func loadFromXib() {
        // standard initialization logic
        Bundle.main.loadNibNamed("SearchView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        backgroundColor = UIColor.ChatSpotColors.LighterGray

    }
    
    
    func closeSearchBar(){
        searchBarLeadingConstraint.priority = UILayoutPriorityDefaultLow
        searchBarWidthConstraint.priority = UILayoutPriorityDefaultHigh
        searchBar.alpha = 0
    }
    
    func openSearchBar(){
        searchBarLeadingConstraint.priority = UILayoutPriorityDefaultHigh
        searchBarWidthConstraint.priority = UILayoutPriorityDefaultLow
        searchBar.alpha = 1
    }

}
