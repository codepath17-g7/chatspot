//
//  AroundMeView.swift
//  chatspot
//
//  Created by Phuong Nguyen on 10/14/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class AroundMeView: UIView {

    @IBOutlet var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubView()
    }
    
    private func initSubView() {
        let nib = UINib(nibName: "AroundMeView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
