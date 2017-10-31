//
//  ActivityView.swift
//  chatspot
//
//  Created by Varun on 10/25/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Foundation
import UIKit

class ActivityView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var activityInfoText: UILabel!
    
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
        Bundle.main.loadNibNamed("ActivityView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        blurBackground()
    }
    
    private func blurBackground() {
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            
            self.contentView.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.contentView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.contentView.insertSubview(blurEffectView, at: 0) // insert blur view under all the views
            
        } else {
            
            self.contentView.backgroundColor = UIColor.ChatSpotColors.SelectedBlue
        }
    }
    
}
