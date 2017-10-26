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
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    convenience init() {
        self.init()
        initSubviews()
    }
    
    private func initSubviews() {
        // standard initialization logic
        Bundle.main.loadNibNamed("ActivityView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    private func blurBackground() {
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.contentView.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.contentView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.contentView.insertSubview(blurEffectView, at: 0) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            self.contentView.backgroundColor = UIColor.ChatSpotColors.LightBlue
        }
    }
    
}
